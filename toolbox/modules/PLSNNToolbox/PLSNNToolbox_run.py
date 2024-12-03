import argparse
import subprocess

parser = argparse.ArgumentParser()

parser.add_argument('-t','--treatment', type=str)
parser.add_argument('-tf', '--trainFlag', type=str)

parser.add_argument('-xnds', '--xNameDataSet', type=str, default='PLSNNPaper')
parser.add_argument('-pf', '--printFlag', type=str)

args = parser.parse_args()

args.trainFlag = str(args.trainFlag).lower()
args.printFlag = str(args.printFlag).lower()

print(args)

setpath= "toolbox/modules/PLSNNToolbox/"
commandline = ["./run_NeuralNetworkPrediction.sh", 
               "/usr/local/MATLAB/MATLAB_Runtime/R2023b",
               args.xNameDataSet,
               args.treatment,
               args.trainFlag,
               args.printFlag]

open('toolbox/modules/PLSNNToolbox/data/treatment.txt', 'w+').write(args.treatment)

print('\n','CMDLINE: ',commandline,'\n')

process = subprocess.Popen(commandline, 
                           cwd=setpath)

