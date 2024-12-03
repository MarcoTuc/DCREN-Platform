import os 
import json

from toolbox.settings import Settings

class Toolbox():
    """
    While the Runner class is needed to instantiate the toolbox on a specific module/method/parameters instance,
    the Toolbox class is more of a working station class where you can get information about which modules are 
    present in the toolbox, which methods they have available and which parameters are needed for each method 
    in order to run it effectively. This will be done after the Runner class is completed    
    """

    SETTINGS_PATH = "toolbox/config"
    SETTINGS_FILE = "GENERAL_settings.json"

    DATABASE_PATH = "data"

    with open(f"{SETTINGS_PATH}/{SETTINGS_FILE}") as file: 
        general_settings = json.load(file) 

    def __init__(self):
        
        self.modules = self.general_settings['modules']['list']
        self.db_formats = ['csv', 'json', 'multiline-csv']#[form for form in os.listdir(self.DATABASE_PATH)]

    def databases(self, format):
        path = f"{self.DATABASE_PATH}/{format}"
        dblist = [name.split('.')[0] for name in os.listdir(path)]
        if "schemas" in dblist:
            dblist.remove('schemas')
        return dblist

    def module_frontend_parameters(self):
        out = {}
        for module in self.modules:
            settings = Settings(module)
            params = {}
            for func in settings.functionalities:
                settings._get_func_params(func)
                try: 
                    params[func] = settings.funconfig['parameters']['show']
                    param_details = {}
                    for param in params[func]:
                        param_details[param] = settings.funconfig['parameters']["properties"][param]
                    params[func] = param_details
                except KeyError: 
                    params[func] = {}
            out[module] = params
        return out 
    
    def module_output_variables(self):
        out = {}
        for module in self.modules:
            settings = Settings(module)
            params = {}
            for func in Settings(module).functionalities:
                settings._get_func_params(func)
                try: params[func] = settings.funconfig['outputs']
                except KeyError: params[func] = []
            out[module] = params
        return out 

    @property
    def modules_display(self):
        return  {Settings(module).allparams['display-name']: module for module in self.modules}

