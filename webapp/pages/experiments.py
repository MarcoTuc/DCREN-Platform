import json
from datetime import date, time
import os
import traceback
import zipfile
import tempfile
import shutil

import reflex as rx
import pandas as pd 

from webapp.navbar import navbar

from toolbox.toolbox import Toolbox
from toolbox.expmanager import Exp
from toolbox.validator import Validator, Oracle
from toolbox.jsonmanager import JsonManager

Exp().pickle()
TB = Toolbox()

class ValidationResult(rx.Base):
    report_variable: str
    report_type: str
    report_validation: dict

class Experiment(rx.Base):

    exp_id: int

    tool: str
    name: str
    date: date
    time: time
    code: str
    path: str
    vald: bool

    vald_report: list[ValidationResult]

    data_info: dict[str, str]

    val_error: bool 
    error: bool 
    cache: bool 
    ground_truth_exists: bool = False


def populate_experiment(experiment, ID):

    val_error = False 
    error = False 
    try:
        tool = experiment["TOOL"]
        name = experiment["NAME"]
        date = experiment["DATE"]
        time = ":".join(experiment["TIME"].split("-")) #from windows-safe path format to universal : format
        code = experiment["CODE"]
        path = experiment["PATH"]
        vald = experiment["VALD"]

        try: data_info = json.load(open(f"{experiment['PATH']}/datainfo.json"))
        except FileNotFoundError: data_info =   {
                                                    "dbname": "not found",
                                                    "extension": "not found",
                                                    "patients_set": "not found"
                                                }

        cache = name[0] == "_"

        val_error = False
        error = False

        error_log_path = os.path.join(experiment['PATH'], 'error.log')
        if os.path.exists(error_log_path):
            error = True

        ground_truth_path = os.path.join(experiment['PATH'], 'ground', 'ground.csv')
        ground_truth_exists = os.path.exists(ground_truth_path)

        if vald:
            try: 
                vald_report = [
                    ValidationResult(
                        report_variable = report["variable"],
                        report_type = report["type"],
                        report_validation = report["validation"]
                    )
                    for report in experiment["REPORT"]
                ]
            except Exception as e:
                print(f"Error when populating the experiment {ID}: {tool}, {name}: {e}")
                val_error = True
                report_variable = "error"
                report_type = "error"
                report_validation = [("error","error")]
                vald_report = [ValidationResult(
                        report_variable=report_variable,
                        report_type=report_type,
                        report_validation=report_validation
                    )]
        else:
            report_variable = ""
            report_type = ""
            report_validation = []
            vald_report = [ValidationResult(
                        report_variable=report_variable,
                        report_type=report_type,
                        report_validation=report_validation
                    )]
            
    
    except Exception as e:
        print(f"Error in populate_experiment: {e}")
        tool = name = date = time = code = path = "Error"
        vald = False
        report_variable = report_type = ""
        report_validation = []
        data_info = {"dbname": "Error", "extension": "Error", "patients_set": "Error"}
        error = True
        val_error = True
        ground_truth_exists = False
        vald_report = [ValidationResult(
                        report_variable=report_variable,
                        report_type=report_type,
                        report_validation=report_validation
                    )]

    return Experiment(
        exp_id=ID,
        tool=tool,
        name=name,
        date=date.date(),
        time=time,
        code=code,
        path=path,
        vald=vald,
        vald_report=vald_report,
        data_info=data_info,
        val_error=val_error,
        error=error,
        cache=cache,
        ground_truth_exists=ground_truth_exists
    )

class ExpState(rx.State):

    ARCHIVE_PATH = "toolbox/archive"

    postcolumns: dict[str, str] =   {
                                        "TID": "Visit ID",
                                        "VAR": "Variable",
                                        "TRP": "Therapy",
                                        "VAL": "Predicted value",
                                        "GRD": "True value"
                                    }

    modules: list[str] = TB.modules_display

    expdb   : pd.DataFrame = pd.read_pickle("toolbox/expdb.pkl")
    columns : list = expdb.columns.tolist()
    
    _all_experiments: list[Experiment] = [
        populate_experiment(experiment, i) for i, experiment in expdb.iterrows()
    ]
    _experiments: list[Experiment] = [
        exp for exp in _all_experiments if not exp.cache
    ]

    sort_value: str = ""

    search_value_tool: str = ""
    search_value_name: str = ""

    up_or_down_tool: bool = True
    up_or_down_name: bool = True
    up_or_down_date: bool = True
    up_or_down_time: bool = True

    is_updating: bool = False

    show_experiment: bool = False
    exp_in_focus: Experiment = _all_experiments[0]
    showNaN: bool = False

    validator_options: list[str] = ["Default", "Custom"]  # Add validator options
    selected_validator: str = "Default"

    selected_experiments_empty: bool = True
    selected_experiments: list[Experiment] = []  # List to store selected experiment IDs
    selected_experiments_IDS: list[int] = []

    continuous_vis_empty: bool = True
    selected_experiments_vis_continuous: list[dict] = [{}]
    continuous_barchart_variables: list[str] = ["MSE"]
    shown_continuous_barchart_variables: list[str] = ["MSE"]

    discrete_vis_empty: bool = True
    selected_experiments_vis_discrete: list[dict] = [{}]
    discrete_barchart_variables: list[str] = ["accuracy", "sensitivity", "specificity"]
    shown_discrete_barchart_variable: str

    download_csv_report_available: bool = False

    selected_dataset: str = ""  # New attribute to store the selected dataset

    show_ground_truth: bool = False  # New attribute for the ground truth checkbox

    confront_view_mode: bool = False # if to go in confront mode or not

    def set_shown_discrete_barchart_variable(self, x):
        self.shown_discrete_barchart_variable = x

    def toggle_experiment_selection(self, exp: Experiment):
        if exp not in self.selected_experiments:
            self.selected_experiments_empty = False
            self.selected_experiments.append(exp)
            self.selected_experiments_IDS.append(exp["exp_id"])
            self.dictionarize_exp(exp)
        else: 
            self.selected_experiments.remove(exp)
            self.selected_experiments_IDS.remove(exp["exp_id"])
            self.remove_exp_from_vis(exp)
            if len(self.selected_experiments) == 0:
                self.selected_experiments_empty = True
    
    def select_deselect_all(self):
        if self.selected_experiments == self.experiments:
            self.selected_experiments = []
            self.selected_experiments_IDS = []
            self.selected_experiments_vis_continuous = [{}]
            self.selected_experiments_vis_discrete = [{}]
            self.selected_experiments_empty = True
        else: 
            self.selected_experiments = self.experiments
            self.selected_experiments_IDS = [exp.exp_id for exp in self.experiments]
            for exp in self.experiments: 
                self.dictionarize_exp_internal(exp)
            self.selected_experiments_empty = False
    
    def download_csv_report(self):

        """
        def handle_post_download(self):
            db_to_download = pd.read_csv(f"{self.exp_in_focus.path}/post/post.csv")
            return rx.download(data=db_to_download.to_csv(), filename=f"{self.exp_in_focus.name}_results.csv")
        """
        dataset = self.selected_dataset
        download_pandas = pd.DataFrame()
        try:
            for exp in self.selected_experiments:
                for report in exp["vald_report"]:
                    for metric, result in report["report_validation"].items():
                        newrow = {
                            "DATA": dataset,
                            "TOOL": exp["tool"],
                            "NAME": exp["name"],
                            "VARIABLE": report["report_variable"],
                            "METRIC": metric,
                            "VALUE": result
                        }
                        download_pandas = pd.concat([download_pandas, pd.DataFrame([newrow])], ignore_index=True)
        except TypeError: 
            for exp in self.selected_experiments:
                for report in exp.vald_report:
                    for metric, result in report.report_validation.items():
                        newrow = {
                            "DATA": dataset,
                            "TOOL": exp.tool,
                            "NAME": exp.name,
                            "VARIABLE": report.report_variable,
                            "METRIC": metric,
                            "VALUE": result
                        }
                        download_pandas = pd.concat([download_pandas, pd.DataFrame([newrow])], ignore_index=True)
        return rx.download(data=download_pandas.to_csv(), filename=f"report.csv")
            


    def dictionarize_exp(self, exp):
        for report in exp["vald_report"]:

            if report["report_type"] == "continuous":
                self.selected_experiments_vis_continuous.append(
                    {
                    "ID": exp["exp_id"],
                    "name": exp["name"],
                    "tool": exp["tool"],
                    "report_variable": report["report_variable"],
                    **report["report_validation"]
                    }
                )
                self.continuous_vis_empty = False

            elif report["report_type"] == "categorical":
                self.selected_experiments_vis_discrete.append(
                    {
                    "ID": exp["exp_id"],
                    "name": exp["name"],
                    "tool": exp["tool"],
                    "report_variable": report["report_variable"],
                    **report["report_validation"]
                    }
                )
                self.discrete_barchart_variables = list(report["report_validation"].keys())
                self.discrete_vis_empty = False
    
    def dictionarize_exp_internal(self, exp):
        for report in exp.vald_report:
            if report.report_type == "continuous":
                self.selected_experiments_vis_continuous.append(
                    {
                    "ID": exp.exp_id,
                    "name": exp.name,
                    "tool": exp.tool,
                    "report_variable": report.report_variable,
                    **report.report_validation
                    }
                )
            elif report.report_type == "categorical":
                self.selected_experiments_vis_discrete.append(
                    {
                    "ID": exp.exp_id,
                    "name": exp.name,
                    "tool": exp.tool,
                    "report_variable": report.report_variable,
                    **report.report_validation
                    }
                )

    def remove_exp_from_vis(self, exp):
        self.selected_experiments_vis_continuous = [
            item for item in self.selected_experiments_vis_continuous
            if item.get("ID") != exp["exp_id"]
        ]
        if len(self.selected_experiments_vis_continuous) == 0:
            self.continuous_vis_empty = True
        self.selected_experiments_vis_discrete = [
            item for item in self.selected_experiments_vis_discrete
            if item.get("ID") != exp["exp_id"]
        ]
        if len(self.selected_experiments_vis_discrete) == 0:
            self.discrete_vis_empty = True

    def change_sort_tool(self):
        self.up_or_down_tool = not self.up_or_down_tool
        self.sort_value = "tool"
    
    def change_sort_name(self):
        self.up_or_down_name = not self.up_or_down_name
        self.sort_value = "name"
    
    def change_sort_date(self):
        self.up_or_down_date = not self.up_or_down_date
        self.sort_value = "date"

    def change_sort_time(self):
        self.up_or_down_time = not self.up_or_down_time
        self.sort_value = "time"
    
    async def update(self):
        self.is_updating = True
        
        Exp().pickle()
        self.expdb = pd.read_pickle("toolbox/expdb.pkl")
        
        self._all_experiments = [
            populate_experiment(experiment, i) for i, experiment in self.expdb.iterrows()
        ]
        self._experiments: list[Experiment] = [
            exp for exp in self._all_experiments if not exp.cache
        ]
        self.is_updating = False
        
    def show_experiment_page(self, ID):
        self.exp_in_focus = self._all_experiments[ID]
        self.show_experiment = True

    def close_experiment_page(self):
        self.show_experiment = False

    @rx.var
    def post_in_focus(self) -> pd.DataFrame:
        try:
            if self.show_ground_truth and self.exp_in_focus.ground_truth_exists:
                focus = pd.read_csv(f"{self.exp_in_focus.path}/ground/ground.csv")
                if self.showNaN:
                    return focus
                else:
                    return focus.dropna(subset=["GRD"])
            else:
                focus = pd.read_csv(f"{self.exp_in_focus.path}/post/post.csv")
                return focus 
            
        except FileNotFoundError:
            print(f"Error: {'ground.csv' if self.show_ground_truth else 'post.csv'} file not found in {self.exp_in_focus.path}/{'ground/' if self.show_ground_truth else 'post/'}")
            return pd.DataFrame()
        except Exception as e:
            print(f"Error loading {'ground.csv' if self.show_ground_truth else 'post.csv'}: {str(e)}")
            return pd.DataFrame()
        
    def switch_show_NaN(self):
        self.showNaN = not self.showNaN

    def set_show_NaN(self, value):
        self.showNaN = value
    
    def handle_post_download(self):
        db_to_download = pd.read_csv(f"{self.exp_in_focus.path}/post/post.csv")
        return rx.download(data=db_to_download.to_csv(), filename=f"{self.exp_in_focus.name}_results.csv")
    
    def handle_folder_download(self):
        if not self.exp_in_focus or not self.exp_in_focus.path:
            return rx.window_alert("No experiment selected or path not found.")

        # Create a temporary directory to store the zip file
        with tempfile.TemporaryDirectory() as temp_dir:
            # Create a zip file name based on the experiment name
            zip_filename = f"{self.exp_in_focus.name}_{self.exp_in_focus.tool}_experiment.zip"
            zip_filepath = os.path.join(temp_dir, zip_filename)

            # Create the zip file
            with zipfile.ZipFile(zip_filepath, 'w', zipfile.ZIP_DEFLATED) as zipf:
                for root, _, files in os.walk(self.exp_in_focus.path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, self.exp_in_focus.path)
                        zipf.write(file_path, arcname)

            # Read the zip file
            with open(zip_filepath, 'rb') as f:
                content = f.read()

        # Return the download component
        return rx.download(
            data=content,
            filename=zip_filename,
            # mime_type="application/zip"
        )
    
    @rx.var
    def unique_datasets(self) -> list[str]:
        return list(set(exp.data_info["dbname"] for exp in self._experiments))

    @rx.var
    def shown_experiments(self) -> list[Experiment]:
        
        self.experiments = self._experiments
        
        # Apply dataset filter
        if self.selected_dataset:
            self.experiments = [
                exp for exp in self.experiments
                if exp.data_info["dbname"] == self.selected_dataset
            ]

        if self.sort_value != "":
            if self.sort_value in ["date", "time"]:
                self.experiments = sorted(
                    self.experiments,
                    key=lambda x: (
                    getattr(x, "date"),
                    getattr(x, "time")
                    ),
                    reverse={
                    "date": self.up_or_down_date,
                    "time": self.up_or_down_time,
                    }[self.sort_value],
                )
            else:
                self.experiments = sorted(
                    self.experiments,
                    key=lambda x: getattr(
                    x, self.sort_value
                    ),
                    reverse={
                    "tool": self.up_or_down_tool,
                    "name": self.up_or_down_name,
                    }[self.sort_value],
                )
        
        if self.search_value_tool != "" and self.search_value_name == "":
            self.experiments = [
                experiment
                for experiment in self.experiments  # Use self.experiments instead of self._experiments
                if any(
                    self.search_value_tool.lower()
                    in getattr(experiment, attr).lower()
                    for attr in [
                    "tool",
                    ]
                )
            ]
        elif self.search_value_name != "" and self.search_value_tool == "":
            self.experiments = [
            experiment
            for experiment in self.experiments  # Use self.experiments instead of self._experiments
            if any(
                self.search_value_name.lower()
                in getattr(experiment, attr).lower()
                for attr in [
                "name",
                ]
            )
            ]
        elif self.search_value_tool != "" and self.search_value_name != "":
            self.experiments = [
            experiment
            for experiment in self.experiments  # Use self.experiments instead of self._experiments
            if any(
                self.search_value_tool.lower()
                in getattr(experiment, attr).lower()
                for attr in [
                "tool",
                ]
            )
            and any(
                self.search_value_name.lower()
                in getattr(experiment, attr).lower()
                for attr in [
                "name",
                ]
            )
            ]

        return self.experiments

    def set_selected_dataset(self, dataset: str):
        self.selected_dataset = dataset
        self.confront_view_mode = True
    
    def null_selected_dataset(self):
        self.selected_dataset = ""
        self.confront_view_mode = False

    def set_selected_validator(self, validator: str):
        self.selected_validator = validator

    def set_show_ground_truth(self, value):
        self.show_ground_truth = value

    async def validate_experiment(self, exp_id: int):

        if not self.exp_in_focus:
            return

        validator = Validator()

        try:
            if self.selected_validator == "Default":
                validation_result = validator.default_validation(self.exp_in_focus.path)
                JsonManager().save_json(validation_result, os.path.join(self.exp_in_focus.path, "validation.json"))
            else:
                validation_result = validator.custom_validation(self.exp_in_focus.path)
            
            temp = []
            for r in validation_result:
                temp.append(
                    ValidationResult(
                        report_variable=r["variable"],
                        report_type=r["type"],
                        report_validation=r["validation"]
                    )
                )
            # Update the experiment with the validation result
            self.exp_in_focus.vald = True
            self.exp_in_focus.vald_report = [*temp]
            self.exp_in_focus.val_error = False
            self.exp_in_focus.error = False

            # Remove error log if it exists
            error_log_path = os.path.join(self.exp_in_focus.path, 'error.log')
            if os.path.exists(error_log_path):
                os.remove(error_log_path)

        except Exception as e:
            # Create error log file
            error_log_path = os.path.join(self.exp_in_focus.path, 'error.log')
            with open(error_log_path, 'w') as f:
                f.write(f"Error during validation: {str(e)}\n")
                f.write(traceback.format_exc())
            
            # Update error flags
            self.exp_in_focus.error = True
            self.exp_in_focus.vald = False
            self.exp_in_focus.val_error = True

        # Update the experiment in the database
        exp_index = next((i for i, exp in enumerate(self._all_experiments) if exp.exp_id == self.exp_in_focus.exp_id), None)
        if exp_index is not None:
            self._all_experiments[exp_index] = self.exp_in_focus
            if not self.exp_in_focus.cache:
                self._experiments = [exp for exp in self._all_experiments if not exp.cache]

        # Update the pickle file
        self.expdb.at[self.exp_in_focus.exp_id, "VALD"] = self.exp_in_focus.vald
        self.expdb.at[self.exp_in_focus.exp_id, "REPORT"] = [validation_result] if not self.exp_in_focus.error else []
        self.expdb.at[self.exp_in_focus.exp_id, "ERROR"] = self.exp_in_focus.error
        self.expdb.to_pickle("toolbox/expdb.pkl")

    async def revalidate_experiment(self):
        await self.validate_experiment(self.exp_in_focus.exp_id)

    async def extract_ground_truth(self):
        if self.exp_in_focus and self.exp_in_focus.path:
            try:
                Oracle(self.exp_in_focus.path)()
                # Check if ground truth file now exists
                ground_truth_path = os.path.join(self.exp_in_focus.path, 'ground', 'ground.csv')
                if os.path.exists(ground_truth_path):
                    self.exp_in_focus.ground_truth_exists = True
                    # Update the experiment in the database
                    exp_index = next((i for i, exp in enumerate(self._all_experiments) if exp.exp_id == self.exp_in_focus.exp_id), None)
                    if exp_index is not None:
                        self._all_experiments[exp_index] = self.exp_in_focus
                        if not self.exp_in_focus.cache:
                            self._experiments = [exp for exp in self._all_experiments if not exp.cache]
                    return rx.window_alert("Ground truth extracted successfully!")
                else:
                    return rx.window_alert("Ground truth extraction completed, but ground.csv file not found.")
            except Exception as e:
                print(f"Error extracting ground truth: {str(e)}")
                return rx.window_alert(f"Error extracting ground truth: {str(e)}")
        else:
            return rx.window_alert("No experiment selected or path not found.")
    
    async def archive_experiment(self):
        if self.exp_in_focus and self.exp_in_focus.path:
            try:
                # Create the archive directory if it doesn't exist
                os.makedirs(self.ARCHIVE_PATH, exist_ok=True)

                # Create the full archive path, maintaining the folder structure
                relative_path = os.path.relpath(self.exp_in_focus.path, start="toolbox/experiments")
                full_archive_path = os.path.join(self.ARCHIVE_PATH, relative_path)

                # Copy the experiment folder to the archive
                shutil.copytree(self.exp_in_focus.path, full_archive_path)

                # Remove the original experiment folder
                shutil.rmtree(self.exp_in_focus.path)

                # Remove the experiment from the database
                self.expdb = self.expdb[self.expdb.index != self.exp_in_focus.exp_id]
                self.expdb.reset_index(drop=True, inplace=True)  # Reset the index
                self.expdb.to_pickle("toolbox/expdb.pkl")

                # Update the experiments list
                self._all_experiments = [
                    populate_experiment(experiment, i) for i, experiment in self.expdb.iterrows()
                ]
                self._experiments = [exp for exp in self._all_experiments if not exp.cache]

                # Close the experiment page
                self.show_experiment = False

                # Sort the experiments
                self.sort_experiments()

                return rx.window_alert("Experiment archived successfully!")
            except Exception as e:
                print(f"Error archiving experiment: {str(e)}")
                return rx.window_alert(f"Error archiving experiment: {str(e)}")
        else:
            return rx.window_alert("No experiment selected or path not found.")

    def sort_experiments(self):
        if self.sort_value:
            if self.sort_value in ["date", "time"]:
                self._experiments.sort(
                    key=lambda x: (getattr(x, "date"), getattr(x, "time")),
                    reverse={
                        "date": self.up_or_down_date,
                        "time": self.up_or_down_time,
                    }[self.sort_value],
                )
            else:
                self._experiments.sort(
                    key=lambda x: getattr(x, self.sort_value),
                    reverse={
                        "tool": self.up_or_down_tool,
                        "name": self.up_or_down_name,
                    }[self.sort_value],
                )

    async def remove_error(self):
        if self.exp_in_focus and (self.exp_in_focus.error or self.exp_in_focus.val_error):
            # Remove the error.log file if it exists
            error_log_path = os.path.join(self.exp_in_focus.path, 'error.log')
            if os.path.exists(error_log_path):
                os.remove(error_log_path)
            
            # Update the experiment state
            self.exp_in_focus.error = False
            self.exp_in_focus.val_error = False

            # Update the experiment in the database
            exp_index = next((i for i, exp in enumerate(self._all_experiments) if exp.exp_id == self.exp_in_focus.exp_id), None)
            if exp_index is not None:
                self._all_experiments[exp_index] = self.exp_in_focus
                if not self.exp_in_focus.cache:
                    self._experiments = [exp for exp in self._all_experiments if not exp.cache]

            # Update the pickle file
            self.expdb.at[self.exp_in_focus.exp_id, "ERROR"] = False
            self.expdb.to_pickle("toolbox/expdb.pkl")

            return rx.window_alert("Error status removed successfully!")
        else:
            return rx.window_alert("No error to remove or no experiment selected.")


def display_validation(validation: list[tuple]):
    return rx.hstack(
        rx.text(f"{validation[0]}: {validation[1]}") 
    )

def popover_validation(experiment):
    return rx.cond(
        ~ experiment.error,
        rx.cond(
            ~ experiment.val_error,
            rx.cond(
                experiment.vald,
                rx.button(
                    "Validated",
                    color_scheme="jade",
                    on_click=ExpState.show_experiment_page(experiment.exp_id),
                ),
                rx.button(
                    "To validate",                
                    on_click=ExpState.show_experiment_page(experiment.exp_id),
                ),
            ),              
            rx.popover.root(
                rx.popover.trigger(
                    rx.button("Val error", variant="surface"),
                ),
                rx.popover.content(
                    rx.vstack(
                        rx.text("There is an error in the validation report"),
                        rx.button(
                            "Open experiment",
                            variant="outline",
                            on_click=ExpState.show_experiment_page(experiment.exp_id),
                        ),
                    ),
                ),
            ),    
        ),
        rx.popover.root(
            rx.popover.trigger(
                rx.button("Error", variant="surface"),
            ),
            rx.popover.content(
                rx.vstack(
                    rx.text("Error in validation pipeline"),
                    rx.hstack(
                        rx.button(
                            "Open experiment",
                            variant="outline",
                            on_click=ExpState.show_experiment_page(experiment.exp_id),
                        ),
                        archive_button(),
                    ),
                ),
            ),
        ),
    )

def exp_checkbox(experiment) -> rx.Component: 
    return rx.checkbox(
               size="2",
               on_change=ExpState.toggle_experiment_selection(experiment),
               checked=ExpState.selected_experiments_IDS.contains(experiment.exp_id),
           )

def showdata(experiment) -> rx.Component:
    return rx.cond(
        ExpState.exp_in_focus.exp_id == experiment.exp_id,
        rx.table.row(
            rx.cond(
                ExpState.confront_view_mode,
                rx.table.cell(
                    exp_checkbox(experiment)
                ),
            ),
            rx.table.row_header_cell(experiment.tool),
            rx.table.cell(experiment.name),
            rx.table.cell(experiment.date),
            rx.table.cell(experiment.time),
            rx.table.cell(popover_validation(experiment)),
            style={"backgroundColor": "#e6f3ff"},
        ),
        rx.table.row(
            rx.cond(
                ExpState.confront_view_mode,
                rx.table.cell(
                    exp_checkbox(experiment)
                ),
            ),
            rx.table.row_header_cell(experiment.tool),
            rx.table.cell(experiment.name),
            rx.table.cell(experiment.date),
            rx.table.cell(experiment.time),
            rx.table.cell(popover_validation(experiment)),
        ),
    )

def table_content():
    return rx.scroll_area(
        rx.vstack(
            rx.hstack(
                rx.select(
                    ExpState.unique_datasets,
                    placeholder="Filter by dataset",
                    on_change=ExpState.set_selected_dataset,
                    value=ExpState.selected_dataset,
                ),
                rx.button(
                    "Exit",
                    on_click=lambda: ExpState.null_selected_dataset,
                    variant="outline",
                ),
            ),
            rx.table.root(
                rx.table.header(
                    rx.table.row(
                        rx.cond(
                            ExpState.confront_view_mode,
                            rx.table.column_header_cell(
                                rx.button(
                                    "",
                                    on_click=ExpState.select_deselect_all,
                                    variant="outline",
                                    size="sm"
                                ),
                            ),
                        ),
                        rx.table.column_header_cell(
                            rx.flex(
                                rx.button(
                                "Method",
                                dynamic_icon(ExpState.up_or_down_tool), 
                                on_click=ExpState.change_sort_tool,
                                variant="surface"
                                ),
                            ),
                        ),
                        rx.table.column_header_cell(
                            rx.flex(
                                rx.button(
                                "Name",
                                dynamic_icon(ExpState.up_or_down_name), 
                                on_click=ExpState.change_sort_name,
                                variant="surface"
                                ),
                            ),
                        ),
                        rx.table.column_header_cell(
                            rx.button(
                            "Date",
                            dynamic_icon(ExpState.up_or_down_date), 
                            on_click=ExpState.change_sort_date,
                            variant="surface"
                            ),
                        ),
                        rx.table.column_header_cell(
                            rx.button(
                            "Time",
                            dynamic_icon(ExpState.up_or_down_time), 
                            on_click=ExpState.change_sort_time,
                            variant="surface"
                            ),
                        ),
                        rx.table.column_header_cell(
                            rx.button(
                                "update table",
                                on_click=ExpState.update,
                                loading=ExpState.is_updating,   
                                color_scheme="grass",
                                variant="surface"
                            )
                        ),
                    ),
                ),
                rx.table.body(
                    rx.foreach(
                        ExpState.shown_experiments,
                        showdata
                    ),
                ),
                variant='surface',
            ),
            type="always",
            scrollbard="vertical",
            style={
                "height": 800
            }
        )
    )

def dynamic_icon(icon_state):
    return rx.match(
        icon_state,
        (True, rx.icon("chevron-up")),
        (False, rx.icon("chevron-down")),
    )

def sorted_table():
    return rx.vstack(
                rx.hstack(
                    rx.input(
                        placeholder="Search by method...",
                        on_change=ExpState.set_search_value_tool,
                        width = "50%"
                    ),
                    rx.input(
                        placeholder="Search by experiment name...",
                        on_change=ExpState.set_search_value_name,
                        width = "70%"
                    ),
                ),
                table_content(),
            margin='2em',
        )

def valid_page() -> rx.Component:
    return rx.cond(
            ExpState.show_experiment,
            rx.vstack(
                rx.hstack(
                    rx.vstack(
                        rx.badge(
                            rx.vstack(
                                rx.text.em("database used:"),
                                rx.text.strong(f"{ExpState.exp_in_focus.data_info['dbname']}"),
                            ),
                        ),
                        rx.badge(
                            rx.vstack(
                                rx.text.em("patients subset:"),
                                rx.text.strong(f"{ExpState.exp_in_focus.data_info['patients_set']}"),
                            ),
                        ),
                    ),
                    rx.vstack(
                        rx.badge(
                            rx.vstack(
                                rx.text.em("Module used"),
                                rx.text.strong(f"{ExpState.exp_in_focus.tool}"),
                            ),
                            color_scheme="iris",
                        ),
                        rx.badge(
                            rx.vstack(
                                rx.text.em("Experiment name:"),
                                rx.text.strong(f"{ExpState.exp_in_focus.name}"),
                            ),
                            color_scheme="iris",
                        ),
                    ),
                    rx.badge(
                        rx.foreach(
                            ExpState.exp_in_focus.vald_report,
                                lambda report: 
                                rx.vstack(
                                rx.text.em("Validation results:"),
                                rx.text.strong(f"Variable: {report.report_variable}"),
                                rx.text.strong(f"Type: {report.report_type}"),
                                rx.foreach(
                                    report.report_validation,
                                    lambda validation: rx.text.strong(f"{validation[0]}: {validation[1]}")
                                ),
                            ),
                        ),
                    ),
                    rx.button(
                        "Extract ground truth",
                        height="100px",
                        width="100px",
                        variant="outline",
                        on_click=ExpState.extract_ground_truth,
                    ),
                    rx.vstack(
                        rx.select.root(
                            rx.select.trigger(placeholder="Select validator"),
                            rx.select.content(
                                rx.select.group(
                                    rx.select.item("default", value=ExpState.validator_options[0]),
                                    rx.select.item("custom", value=ExpState.validator_options[1], disabled=True),
                                )
                            )
                        ),
                        rx.button(
                            "Re-validate",
                            on_click=ExpState.revalidate_experiment,
                        ),
                    ),
                    rx.cond(
                        ExpState.exp_in_focus.error | ExpState.exp_in_focus.val_error,
                        rx.button(
                            "Remove error",
                            on_click=ExpState.remove_error,
                            color_scheme="red",
                            variant="outline",
                        ),
                    ),
                    margin='1em',
                    align_items="center",
                    justify_content="space-between",
                ),
                rx.box(
                    rx.vstack(
                        rx.cond(
                            ExpState.exp_in_focus.ground_truth_exists,
                            rx.checkbox(
                                "Show ground truth",
                                on_change=ExpState.set_show_ground_truth,
                                default_checked=False,
                            ),
                        ),
                        rx.checkbox(
                            "Show rows with no ground truth",
                            on_change=ExpState.set_show_NaN,
                            default_checked=False,
                        ),
                    ),
                    margin="1em",
                ),
                rx.box(
                    rx.data_table(
                        data=ExpState.post_in_focus,
                        pagination=True,
                        search=True,
                        sort=True
                    ),
                    rx.hstack(
                        rx.button("Close", on_click=ExpState.close_experiment_page),
                        rx.button("Download results table", on_click=ExpState.handle_post_download, color_scheme="grass"),
                        rx.button("Download Experiment Folder", on_click=ExpState.handle_folder_download),
                        archive_button(),
                        spacing='2',
                    ),
                    margin='1em',
                ),
                style=box_style,
                margin='1em',
                width='50%',
                spacing="2"
            ),
        )

def archive_button() -> rx.Component:
    return rx.dialog.root(
                rx.dialog.trigger(rx.button("Archive experiment", color_scheme="yellow", variant="outline")),
                rx.dialog.content(
                    rx.dialog.title("Are you sure you want to archive this experiment?"),
                    rx.hstack(
                        rx.button("Archive", on_click=ExpState.archive_experiment, color_scheme="yellow"),
                        rx.dialog.close(
                            rx.button("Close")
                        ),
                    )
                )
            )


def continuous_bar() -> rx.Component:
    return rx.vstack(
        rx.text("L2 Loss"),
        rx.recharts.bar_chart(
            rx.recharts.bar(
                data_key="MSE",
                stroke=rx.color("accent", 8),
                fill=rx.color("accent", 3),
            ),
            rx.recharts.x_axis(type_="number"),
            rx.recharts.y_axis(
                data_key="ID", type_="category"
            ),
            data=ExpState.selected_experiments_vis_continuous,
            layout="vertical",
            margin={
                "top": 20,
                "right": 20,
                "left": 20,
                "bottom": 20,
            },
            width=400,
            height=300,
        )
    )

def discrete_bar() -> rx.Component:
    return rx.vstack(
        rx.text("Target Control validation metrics", as_="label"),
        rx.select(
            ExpState.discrete_barchart_variables,
            on_change=lambda x: ExpState.set_shown_discrete_barchart_variable(x),
            default_value="accuracy"
            ),
        rx.recharts.bar_chart(
            rx.recharts.bar(
                data_key=ExpState.shown_discrete_barchart_variable,
                stroke=rx.color("accent", 8),
                fill=rx.color("accent", 3),
            ),
            rx.recharts.x_axis(type_="number"),
            rx.recharts.y_axis(
                data_key="ID", type_="category"
            ),
            data=ExpState.selected_experiments_vis_discrete,
            layout="vertical",
            margin={
                "top": 20,
                "right": 20,
                "left": 20,
                "bottom": 20,
            },
            width=400,
            height=300,
        )
    )


def confront_page() -> rx.Component:
    return rx.cond(
        ~ ExpState.selected_experiments_empty,
        rx.box(
            rx.vstack(
                rx.button("Download confront results", on_click=ExpState.download_csv_report, color_scheme="grass"),
                continuous_bar(),
                discrete_bar(),
                spacing="2",
                margin="2em"
            ),
            style=box_style,
            margin="1em"
        )
    )

def exp_page() -> rx.Component:
    return rx.hstack(        
            rx.box(
                sorted_table()
            ),
            rx.cond(
                ExpState.confront_view_mode,
                confront_page(),
                valid_page()
            )
        )
    

def experiments() -> rx.Component:
    return rx.box(
        navbar(),
        exp_page(),
    )


box_style = {
        'background_color': '#f2f3f4',
        'border_color': '#b3b3b3',
        'border_width': '1px',
        'border_radius': '15px',
}