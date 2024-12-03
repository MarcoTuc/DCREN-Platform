import os 
import subprocess
import secrets
import json

from shutil import copytree, copy2
from glob import glob
from datetime import datetime

import numpy as np 
import pandas as pd 

from toolbox.datamanager import DataManager
from toolbox.expmanager import Exp
from toolbox.settings import Settings
from toolbox.jsonmanager import JsonManager

SUBCAPTURE = True # If true shell output of modules is hidden
GENERICEXP = 'generic' # Name of generic folder to save stuff into if nothing is given

class Runner():

    """ Running multiple Method instances at the same time by specifying a list of methods to call and
        for each method which functionalities to activate and for each functionality which parameters 

        The <modules> argument can take as input:
            - A list of module names like ['opai','PLSNNToolbox', ... ]
            - A list of Module objects like:
                `   opai  = Module('opai', func='predict', params={})
                    plsnn = Module('PLSNNToolbox', func='predict', params={'treatment'='TS'})
                    rn = Runner([opai, plsnn])
            - A single module name 
            - A single module object 
        
        The <database> argument can take as input: 
            - A database name like dcren-websocket.csv
            - A DataManager object like 
                `   dm = DataManager(dbname='databasename.csv')
                    rn = Runner(<modules>, dm) """

    def __init__(self, modules, database=None):
        
        self.runners = []
        self.database = database

        if isinstance(modules, list):
            for module in modules:
                if isinstance(module, str):
                    self.runners.append(Module(module, database))
                elif isinstance(module, Module):
                    self.runners.append(module)
            self.multiple = True
        elif isinstance(modules, str):
            self.runners = Module(modules, database)
            self.multiple = False
        elif isinstance(modules, Module):
            self.runners = modules
            self.multiple = False

    def run(self):
        time = datetime.now()
        if self.database == None:
            raise Exception
        if self.multiple:
            for runner in self.runners:
                runner.cmd_run(time=time)
        elif not self.multiple:
            self.runners.cmd_run(time=time)
    
    def set_datamanagers(self, datamanager: DataManager):
        if isinstance(self.runners, list):
            for runner in self.runners:
                runner.set_datamanager(datamanager)
        elif isinstance(self.runners, Module):
            self.runners.set_datamanager(datamanager)

    # TODO
            """
            Piazzare un follower di stato sui running che dice: 
                - Modulo che sta runnando
                    - Che sta runnando
                    - Che ha finito 
                    - Se ha finito correttamente o con errore
                        - Se con errore: codice errore   
            """

class Module():
    
    """ Takes care of running a single dcren module and saving its results 
        to the experiments path through the saverun method. """

    def __init__(self,
                model_name,
                database=None,
                func='default',
                params='default',
                ):

        self.model = model_name
        self.database = database
        self.func = func
        self.params = params

        self.settings = Settings(model_name, func, params)

        self.model_name = self.settings.allparams['display-name']

        if self.database != None:
            if isinstance(self.database, str) and "None" not in self.database:
                self.set_datamanager(self.database)

        # On config files, if pre or post processing is empty, then it is not needed
        self.preFlag = len(self.settings.allparams['preprocessing']) > 0
        self.postFlag = len(self.settings.allparams['postprocessing']) > 0
    
    ################################
    ######### DATA METHODS #########

    def set_datamanager(self, database, patients_set='all'):
        if isinstance(database, str):
            self.datamanager = DataManager(dbname=database, patients_set=patients_set)
        elif isinstance(database, DataManager):
            self.datamanager = self.database

    def setsubset(self, list_of_patients):
        if not isinstance(list_of_patients, (list, np.ndarray)):
            raise TypeError('list of patients has to be of type <list>')
        self.datamanager.patsubset(list_of_patients)

    #################################
    ######## RUNNING METHODS ########

    def pre_run(self):
        # Copies selected data inputs to location and preprocesses it if needed
        if self.preFlag:
            self.datamanager.write_to_path(self.settings.prepath)
            pre_template = self.settings.funconfig['preprocessing']
            pre_cmdline  = pre_template.format(**self.settings.allparams)
            pre_cmdline = self.settings._replace_paths(pre_cmdline)
            print('#info: running ' + pre_cmdline)
            subprocess.run(pre_cmdline.split(' '))
        else:
            self.datamanager.write_to_path(self.settings.inpath)

    def post_run(self):
        self.datamanager.write_to_path(self.settings.postpath)
        post_template = self.settings.funconfig['postprocessing']
        post_cmdline  = post_template.format(**self.settings.allparams)
        post_cmdline = self.settings._replace_paths(post_cmdline)
        print('#info: running ' + post_cmdline)
        result = subprocess.run(post_cmdline.split(' '), capture_output=SUBCAPTURE, text=True)

        if result.returncode != 0:
            print(f"Error in post-processing: {result.stderr}")
            return False
        return True

    def cmd_run(self, expname=GENERICEXP, time=datetime.now(), show_results=False):
        if self.model == 'PLSNNToolbox':
            self.roger_run_and_save(expname, time, show_results=show_results)
        else:
            rundetails = self.default_run()
            print(rundetails)
            self.saverun(rundetails, expname=expname, time=time, show_results=show_results)
        return None
    
    def default_run(self):
        self.pre_run()
        cmd_template = self.settings.funconfig['command_line']
        commandline = cmd_template.format(**self.settings.allparams)
        commandline = self.settings._replace_paths(commandline)
        print('#info: running ' + commandline)
        cmdrun = subprocess.run(commandline.split(' '), capture_output=SUBCAPTURE) 
        if self.postFlag: self.post_run()
        return cmdrun
    
    def roger_run_and_save(self, expname, time, show_results=False):
        # if self.settings.params == 'default':
        treatments = self.settings.funconfig['parameters']['properties']['treatment']['choice']
        treatments.remove('all')
        for treatment in treatments:
            self.settings.allparams['treatment'] = treatment
            rundetails = self.default_run()
            save_path = self.saverun(rundetails, expname='_cache', time=time, extra_info=treatment, roger=True)
        self.roger_agglomerate(save_path, expname, show_results=show_results)

    def saverun(self, 
                cmdrun, 
                expname=GENERICEXP, 
                random=secrets.token_hex(4), 
                time=datetime.now(),
                extra_info=None,
                show_results=False,
                roger=False):
        
        if expname == GENERICEXP:
            parentdir = GENERICEXP
        else: 
            parentdir = str(expname)
        
        if time is not None:
            today = '-'.join(map(str,[time.year,time.month,time.day]))
            now = '-'.join(map(str,[time.hour,time.minute,time.second]))
            save_path = f"{self.settings.general_settings['experiments_path']}/{self.settings.model}/{parentdir}/{today}/{now}_RUN_{random}"
            if roger:
                save_path = f"{save_path}/{extra_info}"
        else:
            save_path = f"{self.settings.general_settings['experiments_path']}/{self.settings.model}/{parentdir}"
            
        # Inside the experiment make folders with day and time of experiment + a random base64 string for url safety
        save_prepath = f"{save_path}/pre" 
        save_inpath = f"{save_path}/input"
        save_expath = f"{save_path}/output"
        save_postpath = f"{save_path}/post"
        # Save the inputs/outputs of the experiment in their respective folders
        # Copytree takes care of copying all files and making the needed folders 
        ## Copy the selected input data in multilinecsv format
        if self.preFlag: 
            self.copy(self.settings.prepath, save_prepath)
        else:
            self.copy(self.settings.inpath, save_prepath)    
        ## Copy the standard input of the method (different than pre multilinecsv format)
        self.copy(self.settings.inpath, save_inpath)
        ## Copy the standard output of the method (different than post format)
        self.copy(self.settings.expath, save_expath)
        ## Copy the postprocessed stuff 
        if self.postFlag: 
            self.copy(self.settings.postpath, save_postpath)
        else:
            self.copy(self.settings.expath, save_postpath)
        # Save the json config that refers to this run 
        self.settings.save_json(self.settings.config, f"{save_path}/config-{self.model}.json")
        self.datamanager.save_info(f"{save_path}/datainfo.json")
        # Save the stdout and stderr of the experiment run
        try:
            open(f'{save_path}/stdout.txt','w+').write(cmdrun.stdout.decode())
            open(f'{save_path}/stderr.txt','w+').write(cmdrun.stderr.decode())
        except AttributeError: print('There has been an error in saving stdout and stderr')

        # Remove the automatic validation
        # if show_results and self.settings.function != "preprocessing":
        #     Exp().validate_single(save_path)

        JsonManager().save_json({
                                "database": self.database,
                                "functionality": self.func,
                                "parameters": self.params
                                }, 
                                f"{save_path}/rundetails.json")

        return save_path

    def roger_agglomerate(self, path, expname, show_results=False):
        aggpath = path.split('/')[:-1]
        path = '/'.join(aggpath)
        agglomerate = []
        for p in glob(f"{path}/*"):
            agglomerate.append(pd.read_csv(f"{p}/post/post.csv"))
        aggpath[-3] = expname
        aggpath = '/'.join(aggpath)
        os.makedirs(f"{aggpath}/post")
        pd.concat(agglomerate).to_csv(f"{aggpath}/post/post.csv", index=False)
        self.datamanager.save_info(f"{aggpath}/datainfo.json")
        
        # Remove the automatic validation
        # if show_results:
        #     Exp().validate_single(aggpath)


    # Takes care of every copying situation
    def copy(self, inpath, outpath):
        if os.path.isdir(inpath):
            copytree(inpath, outpath)
        elif os.path.isfile(inpath):
            os.makedirs(outpath)
            copy2(inpath, outpath)
        else:
            raise LookupError(f"path {inpath} to copy from doesn't exist inside the module")