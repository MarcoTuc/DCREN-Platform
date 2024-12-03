import pandas as pd

outdf = pd.read_csv('toolbox/modules/opai/output_files/temp/OPAi-prediction-output.csv')
tidref = pd.read_csv('toolbox/modules/opai/input_files/temp/OPAi-prediction-input-reference.csv')
tidref = tidref[['TID', 'AGGID']]

# OPAi only predicts Target Control, hence it is hard defined here, to improve? 
action = 'TC'
# Dictionary to translate therapy names from OPAi to standard names
therapies = {'RASi':    'R', 
             'GLP1a':   'RG', 
             'MCRA':    'RM', 
             'SGLT2i':  'RS'}

outdf['TID'] = tidref['AGGID']    

postdf = pd.DataFrame()

groundmap = {
    'controlled':   0,
    'uncontrolled': 1,
    'inbetween':    1,
    None:           None
}

for i, row in outdf.iterrows():
    for therapy in therapies.keys():
        newrow = {'TID': row['TID'], 
                  'VAR': action, 
                  'TRP': therapies[therapy], 
                  'VAL': row[therapy]
                  }
        postdf = pd.concat([postdf, pd.DataFrame([newrow])], ignore_index=True)

postdf.to_csv('toolbox/modules/opai/postprocessed/post.csv',index=False)



########################################### TODO: ROUTINES FOR GRAPH GENERATION
# import networkx as nx 
# from networkx.drawing.nx_agraph import graphviz_layout
# import matplotlib.pyplot as plt  

# # Path to opai graph description
# VSVSPATH = 'toolbox/modules/opai/input_files/origin/VS-VS-assignment.csv'
# REF_ASVSPATH = 'toolbox/modules/opai/input_files/origin/ref-AS-VS-assignment.csv'

# # Put csvs into dataframes
# vdf = pd.read_csv(VSVSPATH)
# ref = pd.read_csv(REF_ASVSPATH)

# # Make a digraphn from the Virtual States transition 
# edges = [(vdf['virtual state ID'][index],vdf['(next) virtual state ID'][index])for index in vdf.index]
# G = nx.from_edgelist(edges, create_using=nx.DiGraph)
# G.remove_edges_from(nx.selfloop_edges(G))

# # Assign weight to each node based on how many actual states are in it 
# weights = ref['virtual state ID'].value_counts()
# for node, weight in weights.items():
#     G.nodes[node]['weight'] = weight


# reordered = outdf.columns.to_list()
# reordered.remove('AGGID')
# reordered.insert(1, 'AGGID')
# outdf = outdf[reordered]