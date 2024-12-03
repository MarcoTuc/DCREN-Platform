import os 
import json 
from shutil import copytree


class Settings():

    """ The Settings class is a core class that manages inter-language running of modules. 
        This class interacts with the json-based configuration files of the toolbox. """

    SETTINGS_PATH = "toolbox/config"
    SETTINGS_FILE = "GENERAL_settings.json"
    PATHS_FILE = "relative_paths.json"

    with open(f"{SETTINGS_PATH}/{SETTINGS_FILE}") as file: 
        general_settings = json.load(file)    

    def __init__(self, 
                 model_name=None, 
                 func='default', 
                 params='default',
                 empty = False):
        
        self.empty = empty
        self.params = params
        self.func_params = {}
        # Check if module is implemented in the toolbox
        if model_name in self.general_settings['modules']['list']:
                self.model = model_name
                self.config = self._get_module_config()
        else: 
            raise NameError(f'Module {model_name} is not implemented')

        self.functionalities = self._get_functionalities()

        self.paths_map = json.load(open(f"{self.SETTINGS_PATH}/{self.PATHS_FILE}"))
        # Retrieve functionality internal parameters to join with module-wide parameters 
        if func == 'default':
            self._get_func_params(self.config['default_functionality'])
        elif func in self.functionalities:
            self._get_func_params(func)
        else: raise NameError(f"Functionality {func} is not implemented")
            
        if isinstance(params, dict):
            self._assign_params(params)
            self.allparams = self.config | self.funconfig | self.params
            try:
                if isinstance(self.funconfig["json_params_template"], dict): 
                    self._dump_json_config()
            except KeyError: pass
        elif params == 'default': 
            self.allparams = self.config | self.funconfig | self._default_params()
            try:
                if isinstance(self.funconfig["json_params_template"], dict): 
                    self._dump_json_config()
            except KeyError: pass 
        else: 
            raise SyntaxError(f"Params has to be of type 'dict' or can be set to params='default'")
        
        self._get_paths()

    ################################################ # # # # # # # # # # # # # # # # # # # # # # # # #
    ###### INTERNAL INITIALIZATION METHODS ######## # # # # # # # # # # # # # # # # # # # # # # # # # #

    def _get_module_config(self):
        with open(f"{self.SETTINGS_PATH}/config-{self.model}.json") as file:
            return json.load(file) 
    
    def _get_functionalities(self) -> list:
        return [obj['name'] for obj in self.config['functionalities']]

    def _get_func_params(self, func):
        if func in self.functionalities:
            self.function = func
            self.funconfig = list(filter(lambda x: x['name'] == func, self.config['functionalities']))[0]
            # self.func_params = list(self.funconfig['parameters']['properties'].keys())
            try: self.func_params = list(self.funconfig['parameters']['properties'].keys())
            except KeyError: pass # means that the module has no parameters to set 
        else: raise NameError(f"Functionality {func} doesn't belong to the method")
    
    def _replace_paths(self, string):
        for path in self.paths_map.items():
            string = string.replace(*path)
        return string
    
    def _assign_params(self, params: dict):
        self.params = {}
        for parkey, parval in params.items():
            if parkey not in self.func_params:
                raise KeyError(f"Parameter {parkey} is not part of functionality {self.function}")
            else:
                self.params[parkey] = parval 
        for fparkey in self.func_params:
            if fparkey not in params:
                try: self.params[fparkey] = self.funconfig['parameters']['properties'][fparkey]['default']
                except KeyError: raise KeyError(f"Parameter {fparkey} has no DEFAULT value, provide it as input")
    
    def _default_params(self):
        if self.empty:
            return {}
        def_pars = {}
        try: def_dict = self.funconfig['parameters']['properties']
        except KeyError: return def_pars
        for parkey, parval in def_dict.items():
            try: def_pars[parkey] = def_dict[parkey]['default']
            except KeyError: raise KeyError(f"Parameter {parkey} has no DEFAULT value, provide it as input")
        return def_pars

    def _get_paths(self):
        self.prepath = self.allparams['standard_preprocessing_path'].format(**self.config)
        self.postpath = self.allparams['standard_postprocessing_path'].format(**self.config)
        inpath = self.allparams['standard_input_path'].format(**self.config)
        expath = self.allparams['standard_output_path'].format(**self.config)
        try: inpath = inpath+'/'+self.allparams['input_name']
        except KeyError: pass
        try: expath = expath+'/'+self.allparams['output_name']
        except KeyError: pass
        self.inpath = inpath
        self.expath = expath

    def _dump_json_config(self):
        """ When a method uses a config.json configuration file, this method dumps it
            inside the experiment folder to help check it. """
        template = self.funconfig['json_params_template']
        for key, val in template.items():
            try: template[key] = val.format(**self.allparams)
            except AttributeError:
                for key2, val2 in template[key].items():
                    template[key][key2] = val2.format(**self.allparams)    
        configpath = self.funconfig['json_params_path'].format(**self.allparams)
        os.makedirs(os.path.dirname(configpath), exist_ok=True)
        self.save_json(template, configpath)
    
    def save_json(self, data, path):
        with open(path,'w+') as config:
            json.dump(data, config, indent=4)


    ######################################### # # # # # # # # # # # # # # # # # # # # # # # # # #
    ########### HELPER METHODS ############# # # # # # # # # # # # # # # # # # # # # # # # # # # 

    def override_config(self, newconfig: dict):
        for key, value in newconfig.items():
            self.funconfig[key] = value


    ######################################### # # # # # # # # # # # # # # # # # # # # # # # # # #
    ########### SAFETY METHODS ############# # # # # # # # # # # # # # # # # # # # # # # # # # # 


