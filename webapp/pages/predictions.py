import io
import os 
import json
from copy import copy

import pandas as pd 
import reflex as rx

from webapp.navbar import navbar
from webapp.components.data.patient_form import manual_patient_input
# from webapp.components.dynoselect import dynoselect, dynoselect_custom

from toolbox.datamanager import DataBase, DataManager
from toolbox.toolbox import Toolbox
from toolbox.runners import Module

# from webapp.components.buttone.buttone import Buttone, dyno_select
# buttone = Buttone.create

MAPPING_PATH = "data/mappings/"

# ---------------------------------- Toolbox backend classes

DB = DataBase()
TB = Toolbox()

# ---------------------------------- Global variables

description_mapping = json.load(open("data/json/schemas/description_mapping.json"))
mapping = [
            {
            "value": key,
            "label": key,
            "keywords": value,
            }
            for key, value in description_mapping.items()
        ]

AVAIL_DATABASES = [database for _, databases in DB.app_databases().items() for database in databases]

MODULES = TB.modules_display
MODULE_PARAMETERS = TB.module_frontend_parameters()

# ---------------------------------- Custom variables&methods of the page 
class Param(rx.Base):
    name   : str
    title  : str               
    type   : str
    haschoice   : bool
    choice : list[str]
    hasdefault  : bool 
    value: str

    def set_value(self, value):
        self.value = value 

def populate_param(paramname, params):
    paramtitle = params[paramname]["title"]
    paramtype = params[paramname]["type"]
    try: 
        if isinstance(params[paramname]["choice"], list): 
            paramchoice = params[paramname]["choice"]
            # print(paramchoice)
            haschoice = True
    except KeyError:
        haschoice = False
        paramchoice = ["none"]
        # print(paramchoice)
    try: 
        paramdefault = params[paramname]["default"]
        hasdefault = True
    except: 
        paramdefault = "none"
        hasdefault = False 
    
    return Param(
        name=paramname, 
        title=paramtitle, 
        type=paramtype,
        haschoice=haschoice,
        choice=list(paramchoice),
        hasdefault=hasdefault,
        value=paramdefault
    )

def populate_params(paramnames, params):
    return [populate_param(paramname, params) for paramname in paramnames]

# --------------------------------- PAGE STATE

class PredState(rx.State):

    # ---- DATABASE RELATED
    databases   : list[str] = AVAIL_DATABASES
    database    : str  = databases[0]
    _descmap    : dict[str,str] = description_mapping
    _mapping    : list[dict[str, str]] = [
            {
            "value": key,
            "label": key,
            "keywords": value,
            }
            for key, value in _descmap.items()
        ]
    
    variable_mappings: dict[str, str] = {}
    savemappingname: str = ""
    mapping_selected: bool = False
    selected_mapping: dict[str, str]
    available_mappings: list[str] = [f for f in os.listdir(MAPPING_PATH)]
    mapping_file: str

    _labels: list[str] = list(_descmap.keys())
    labels_search: str = ""
    _descrs: list[str] = list(_descmap.values())
    varmap_page: int = 0
    varperpage: int = 6
    totpages: int

    newvariables: list[str]
    processdownload : bool = False
    upload_error: str = ""  
    show_error_dialog: bool = False 
    
    file_exists: bool = False
    existing_file_name: str = ""
    rename_mode: bool = False
    new_file_name_without_extension: str = ""  # New state variable
    rename_button_disabled: bool = True
    uploaded_df: pd.DataFrame = pd.DataFrame()  # Store the uploaded DataFrame
    uploaded_file_name: str = ""
    show_selected_file: bool = False
    selected_file_name: str = ""

    varmaps: list = []

    # ---- MODULES RELATED
    namemap : dict      = MODULES
    paramap : dict      = MODULE_PARAMETERS
    modules : list[str] = list(namemap.keys())
    module  : str       = modules[1]
    backname: str       = namemap[module]
    running : bool = False
    funcs   : list[str] = list(paramap[backname].keys())
    func    : str       = funcs[0]
    params      : dict[str, dict]   = paramap[backname][func]
    paramnames  : list[str]         = list(paramap[backname][func].keys())
    parameters  : list[Param]       = populate_params(paramnames, params)
    hasparams   : bool          

    # ---- RUNNING RELATED
    experiment_name : str = ""

    def set_dataset(self, database):
        self.database = database
    
    def set_experiment_name(self, expname):
        self.experiment_name = expname.strip()

    def set_module(self, module):
        self.module = module
        self.set_func()
    
    def set_func(self):
        self.backname = self.namemap[self.module]
        self.funcs = list(self.paramap[self.backname].keys())
        self.get_params()
    
    def get_params(self):
        self.func = self.funcs[0]
        self.params = self.paramap[self.backname][self.func]
        self.paramnames = list(self.paramap[self.backname][self.func].keys())
        self.parameters = populate_params(self.paramnames, self.params)    
        self.hasparams  = len(self.parameters) > 0
    
    async def handle_run_experiment(self):
        self.running = True
        yield
        # print({param.name: param.value for param in self.parameters})
        try:
            runner = Module(
                self.backname, 
                self.database,
                func=self.func,
                params={param.name: param.value for param in self.parameters})
            runner.cmd_run(expname=self.experiment_name)
        finally:
            self.running = False
    
    def db_to_download(self):
        dm = DataManager(self.database)
        db_to_download = pd.read_csv(dm.datapath)
        return rx.download(data=db_to_download.to_csv(), filename=f"{self.database}")
        
    async def handle_upload_stage_1(self, files: list[rx.UploadFile]):
        if not files:
            self.upload_error = "No file selected."
            return

        file = files[0]
        _, file_extension = os.path.splitext(file.filename)

        if file_extension.lower() != '.csv':
            self.upload_error = "Only CSV files are allowed."
            self.show_error_dialog = True
            return

        # Read the file content directly into a DataFrame
        file_content = await file.read()
        self.uploaded_df = pd.read_csv(io.BytesIO(file_content))
        self.uploaded_file_name = file.filename
        self.selected_file_name = file.filename
        self.show_selected_file = True

        # Check if file already exists
        if os.path.exists(os.path.join("data/csv/", file.filename)):
            self.file_exists = True
            self.existing_file_name = file.filename
            self.upload_error = f"A file named '{file.filename}' already exists."
            self.show_error_dialog = True
            return

        self.process_uploaded_file()

    def process_uploaded_file(self):
        self.file_exists = False
        self.existing_file_name = ""
        self.upload_error = ""  # Clear any previous error
        self.show_error_dialog = False
        self.newvariables = self.uploaded_df.columns.tolist()
        self.totpages = len(self.newvariables) // self.varperpage
        self.processdownload = True

    def enter_rename_mode(self):
        self.rename_mode = True
        self.new_file_name_without_extension = self.existing_file_name.rsplit('.', 1)[0]

    def set_new_file_name(self, name: str):
        # Remove any extension the user might have added
        self.new_file_name_without_extension = name.split('.')[0]
        
        # Check if the new file name (with .csv) already exists
        new_file_name = f"{self.new_file_name_without_extension}.csv"
        self.rename_button_disabled = (
            new_file_name == "" or 
            os.path.exists(os.path.join("data/csv/", new_file_name))
        )

    def handle_rename(self):
        if not self.rename_button_disabled:
            new_file_name = f"{self.new_file_name_without_extension}.csv"
            self.uploaded_file_name = new_file_name
            self.existing_file_name = ""
            self.file_exists = False
            self.show_error_dialog = False
            self.rename_mode = False
            self.show_selected_file = True
            self.process_uploaded_file()
        else:
            return rx.toast(
                title="Error",
                description="Please enter a new, unique file name.",
                status="error",
            )
        
    @rx.var
    def get_variable_mapping(self) -> dict[str, str]:
        return self.variable_mappings

    def set_variable_mapping(self, variable: str, mapping: str):
        self.variable_mappings[variable] = mapping

    def handle_overwrite(self):
        self.file_exists = False
        self.show_error_dialog = False
        self.process_uploaded_file()

    def handle_cancel_upload(self):
        self.file_exists = False
        self.existing_file_name = ""
        self.show_error_dialog = False
        self.processdownload = False
        self.uploaded_df = pd.DataFrame()  # Clear the DataFrame
        self.uploaded_file_name = ""
        self.newvariables = []
        self.varmap_page = 0
        self.totpages = 0
        self.variable_mappings = {}
        self.show_selected_file = False
        self.selected_file_name = ""

    async def confirm_upload_and_mapping(self):
        if not self.uploaded_df.empty and self.uploaded_file_name:
            # Apply the mapping to update column names
            self.uploaded_df = self.apply_variable_mapping(self.uploaded_df)
            
            outfile = os.path.join("data/csv/", self.uploaded_file_name)
            self.uploaded_df.to_csv(outfile, index=False)
            
            # Clear the stored DataFrame after saving
            self.uploaded_df = pd.DataFrame()
            self.uploaded_file_name = ""
            self.processdownload = False
            self.variable_mappings = {}  # Clear the mappings after use
            return rx.window_alert("File uploaded successfully with updated variable names!")
        else:
            return rx.window_alert("No file to upload or file name is missing.")

    def apply_variable_mapping(self, df: pd.DataFrame) -> pd.DataFrame:        
        # Rename the columns using the mapping
        df = df.rename(columns=self.variable_mappings)
        return df

    def close_error_dialog(self):
        self.show_error_dialog = False

    def delete_variable_mapping(self):
        os.remove(f"{MAPPING_PATH}{self.mapping_file}")
        self.mapping_selected = False
        self.update_available_mappings()

    def update_available_mappings(self):
        self.available_mappings = [f for f in os.listdir("data/mappings/")]

    def set_selected_mapping(self, mapping):
        self.mapping_selected = True
        self.mapping_file = mapping
        with open(MAPPING_PATH + mapping, "r") as f:
            self.selected_mapping = json.load(f)
        # Populate the variable_mappings with the selected mapping
        self.variable_mappings = self.selected_mapping
        # Update the select items for each variable
        self.update_select_items()

    def update_select_items(self):
        for var in self.newvariables:
            if var in self.variable_mappings:
                # If the variable is in the mapping, set its value
                self.set_variable_mapping(var, self.variable_mappings[var])

    def save_variable_mappings(self):
        if self.savemappingname != "":
            with open(MAPPING_PATH + self.savemappingname + ".json", "w") as f:
                json.dump(self.variable_mappings, f)
        else:
            self.upload_error = "Please name your mapping"
            self.show_error_dialog = True

    @rx.var
    def varmappingpage(self) -> list[str]:
        return self.newvariables[self.varmap_page*self.varperpage:(self.varmap_page+1)*self.varperpage]
    
    @rx.var
    def shown_varmaps(self) -> list[str]:
        self.varmaps = self.newvariables[self.varmap_page*self.varperpage:(self.varmap_page+1)*self.varperpage]
        return self.varmaps
    
    def next_page(self):
        self.varmap_page += 1

    def prev_page(self):
        self.varmap_page -= 1

    def set_search(self, search):
        self.search_labels = search

    @rx.var
    def show_search(self) -> list[str]:    
        self.labels = self._labels
        if self.labels_search != "":
            self.labels = [
                label 
                for label in self._labels
                if self.labels_search.lower() in label.lower()
                ]
        return self.labels

    @rx.var
    def new_file_name(self) -> str:
        return f"{self.new_file_name_without_extension}.csv"

#----------------------------------------------
# ---------------------------------- DATA BLOCK
#----------------------------------------------

def check_data_page():
    return rx.hstack(
            rx.select(
                PredState.databases,
                placeholder="Select dataset",
                width="40%",
                name='select',
                on_change=PredState.set_dataset
            ),
            rx.button('Select', width='30%', type="submit"),
            rx.button(
                'Download', 
                on_click=PredState.db_to_download,
                width='20%', 
                color_scheme='iris',
            ),
            #TODO: the inspect button should send info to the backend and open up a frontend hover of it that the user can explore
            align='center',  
            spacing = '2',
            margin='1em',
            width = '100%',
        ),

color = "rgb(107,99,246)"

def varmapper(var) -> rx.Component:
    return rx.hstack(
            rx.popover.root(
                rx.button(
                    rx.text(f"{var}", align='right'),
                    width="40%", variant="outline", color_scheme="iris"
                ),
            rx.icon("arrow-right-from-line"),
            rx.select(
                PredState._labels,
                width="40%",
                on_change=lambda value: PredState.set_variable_mapping(var, value),
                value=PredState.get_variable_mapping[var],  # Use the computed var here
                key=f"select_{var}"  # This makes each select unique
            ),
            margin='1em',
            spacing="1",
        )
    )

def error_dialog():
    return rx.dialog.root(
        rx.dialog.content(
            rx.dialog.title("File Already Exists"),
            rx.dialog.description(PredState.upload_error),
            rx.cond(
                PredState.rename_mode,
                rx.vstack(
                    rx.input(
                        placeholder="Enter new file name (without extension)",
                        on_change=PredState.set_new_file_name,
                        value=PredState.new_file_name_without_extension,
                    ),
                    rx.text(f"File will be saved as: {PredState.new_file_name}"),
                    rx.button(
                        "Confirm Rename",
                        on_click=PredState.handle_rename,
                        disabled=PredState.rename_button_disabled,
                    ),
                    rx.cond(
                        PredState.rename_button_disabled,
                        rx.box(
                            rx.text("Filename exists"),
                            padding="1em",
                            background_color="rgb(254, 215, 215)",
                            border_radius="1em",
                            border="1px solid rgb(252, 129, 129)",
                        ),
                    ),
                ),
                rx.vstack(
                    rx.text(f"File '{PredState.existing_file_name}' already exists."),
                    rx.hstack(
                        rx.button("Change Name", on_click=PredState.enter_rename_mode),
                        rx.button("Overwrite", on_click=PredState.handle_overwrite),
                        rx.button("Cancel Upload", on_click=PredState.handle_cancel_upload),
                    ),
                ),
            ),
        ),
        open=PredState.show_error_dialog,
    )

def load_data_page():
    return rx.vstack(
            rx.hstack(
                rx.upload(
                    rx.text("Drag & drop files or click"),
                    id="upload_data",
                    border=f"1px dotted {color}",
                    padding="5em",
                ),
                rx.vstack(
                    rx.button(
                        "Upload",
                        on_click=PredState.handle_upload_stage_1(rx.upload_files(upload_id="upload_data")),
                    ),
                    rx.button(
                        "Clear",
                        on_click=[rx.clear_selected_files("upload_data"), PredState.handle_cancel_upload],
                        variant="outline",
                    ),
                    rx.cond(
                        PredState.show_selected_file,
                        rx.text(PredState.uploaded_file_name)
                    ),
                ),
            ),
            error_dialog(),
            rx.cond(
                PredState.processdownload,
                rx.box(
                    rx.divider(),
                    rx.heading("Define variables", size='4'),
                    rx.text(""" Define the correspondence of new variables with dcren variables """, align='center'),
                    rx.drawer.root(
                        rx.drawer.trigger(rx.button("Use existing mappings", margin="1em")),
                        rx.drawer.portal(
                            rx.drawer.content(
                                rx.vstack(
                                    rx.hstack(
                                        rx.select(
                                            items=PredState.available_mappings,
                                            placeholder="Select mapping",
                                            on_change=PredState.set_selected_mapping,
                                            width="20em%",
                                        ),
                                        rx.button(
                                            "update",
                                            on_click=PredState.update_available_mappings
                                        ),
                                        rx.drawer.close(rx.button("Close"))
                                    ),
                                    rx.cond(
                                        PredState.mapping_selected,
                                        rx.vstack(
                                            rx.button(
                                                "Delete mapping",
                                                on_click=PredState.delete_variable_mapping
                                                ),
                                            rx.foreach(
                                                PredState.selected_mapping,
                                                lambda x: rx.hstack(
                                                            rx.text(x[0]),
                                                            rx.text("-->"),
                                                            rx.text(x[1])
                                            )
                                        )
                                    )
                                ),
                            ),
                            top="auto",
                            left="auto",  # Change this from 'left' to 'right'
                            height="100%",
                            width="30em",
                            padding="2em",
                            background_color="#FFF"
                            )
                        ),
                        direction="right",
                    ),
                    rx.grid(
                        rx.foreach(
                            PredState.shown_varmaps,
                            lambda i: varmapper(i)
                        ),
                        rx.hstack(
                            rx.button(
                                "Prev",
                                on_click=PredState.prev_page,
                            ),
                            rx.text(
                                f"Page {PredState.varmap_page+1} / {PredState.totpages}"
                            ),
                            rx.button(
                                "Next",
                                on_click=PredState.next_page,
                            ),
                        ),
                        rx.hstack(
                            rx.input(
                                placeholder="Name the mapping...",
                                on_change=PredState.set_savemappingname
                                ),
                            rx.button(
                                "Save mapping",
                                on_click=PredState.save_variable_mappings,
                                )
                        ),
                        spacing="3",
                        rows="3",
                        align="center",
                    ),
                    # Add the confirmation button here
                    rx.button(
                        "Cancel Upload",
                        on_click=PredState.handle_cancel_upload,
                        color_scheme="red",
                        size="md",
                        margin_top="1em",
                    ),
                    rx.button(
                        "Confirm Upload and Mapping",
                        on_click=PredState.confirm_upload_and_mapping,
                        color_scheme="green",
                        size="lg",
                        margin_top="1em",
                    ),
                )
            ),
        margin='1em',   
        )


def insert_patient_page():
    return rx.box(
        manual_patient_input(),
        margin='1em'
    )

def data_block():
    return rx.box(
            rx.heading("Data", size='5'),
            rx.tabs.root(
                rx.tabs.list(
                    rx.tabs.trigger("Use existing datasets", 
                                    value="check_data",
                                    width='33%'
                                    ),
                    rx.tabs.trigger("Upload data", 
                                    value="load_data",
                                    width='33%'
                                    ),
                    rx.tabs.trigger("Insert patient", 
                                    value="single_patient",
                                    width='33%'
                                    ),
                ),
                rx.tabs.content(
                    check_data_page(),
                    value="check_data"
                ),
                rx.tabs.content(
                    load_data_page(),
                    value="load_data"
                ),
                rx.tabs.content(
                    insert_patient_page(),
                    value="single_patient"
                ),
                default_value='check_data'
            ),
            style=box_style,
            width = '33%',
            text_align = 'center'
        ),

# ----------------------------------------------
# ---------------------------------- MODEL BLOCK
# ----------------------------------------------

def model_block():
    return rx.box(
            rx.heading("Models", size='5'),
            rx.divider(),
            rx.hstack(
                rx.vstack(
                    rx.text('Select module'),
                    rx.select(
                        PredState.modules,
                        value = PredState.module,
                        on_change = lambda x: PredState.set_module(x),
                    ),
                    width = '15%',
                    margin = '1em'
                ),
                rx.vstack(
                    rx.text('Select function'),
                    rx.select(
                        PredState.funcs,
                        value = PredState.func,
                        on_change = lambda x: PredState.get_params(x), 
                        ),
                    width = '15%',
                    margin = '1em'
                ),
                rx.cond(
                    PredState.hasparams,
                    rx.vstack(
                        rx.text('Insert parameters'),
                            rx.foreach(PredState.parameters,
                                lambda p: 
                                rx.hstack(
                                    rx.text(p.name),
                                    parameters_visualization(p)
                                ),
                            ),
                        width = '60%',
                        margin = '1em'
                    ),
                    rx.text(f"Module {PredState.module} has no tunable parameters", margin = '1em'),
                ),
            ),
            style=box_style,
            width = '33%',
            text_align = 'center'
        )

def parameters_visualization(p):
    return rx.box(
            rx.cond(
                p.type == "string",
                rx.cond( 
                    p.haschoice,
                    rx.select(
                        p.choice, 
                        default_value=p.value,
                        # on_change= lambda x: p.set_value(x)
                    ),
                    rx.input(placeholder="define parameter")
                ),
                rx.cond(
                    p.type == "boolean",
                    rx.checkbox(),
                    rx.cond(
                        p.type == "number",
                        rx.chakra.number_input(
                        )
                    )
                )
            )
        )

# ------------------------------------------------
# ---------------------------------- RESULTS BLOCK
# ------------------------------------------------

def results_block():
    return rx.box(
            rx.heading("Results", size='5'),
            rx.divider(),
            rx.vstack(
                rx.input(
                    placeholder="Name your experiment",
                    on_blur=PredState.set_experiment_name,
                    width='100%',
                ),
                running_button_dynamics(),
                margin='1em',
                width='80%',
                align='center'
            ),
            style=box_style,
            width = '33%',
            text_align = 'center'
        )

def running_button_dynamics():
    return rx.cond(
        PredState.experiment_name != "",
        rx.button(
            "Run the experiment",
            on_click=PredState.handle_run_experiment,
            color_scheme='grass',
            width='100%',
            loading=PredState.running
        ),
        rx.button(
            "Run the experiment",
            on_click=rx.toast.error("Please name your experiment first"),
            color_scheme='grass',
            width='100%',
        )
    )

# ------------------------------------------------
# ---------------------------------- COMPLETE PAGE
# ------------------------------------------------

def predictions_page():
    return  rx.hstack(
                data_block(),
                model_block(),
                results_block(),
                justify='between',
                align='start',
                padding = "8px"
            )

def predictions() -> rx.Component:
    return rx.box(
            navbar(),
            predictions_page()
    )


box_style = {
        'background_color': '#f0f0f0',
        'border_color': '#b3b3b3',
        'border_width': '1px',
        'border_radius': '15px',
}