!pip install networkx
!pip install pybbn

import pandas as pd # for data manipulation
import networkx as nx # for drawing graphs
import matplotlib.pyplot as plt # for drawing graphs
# for creating Bayesian Belief Networks (BBN)
from pybbn.graph.dag import Bbn
from pybbn.graph.edge import Edge, EdgeType
from pybbn.graph.jointree import EvidenceBuilder
from pybbn.graph.node import BbnNode
from pybbn.graph.variable import Variable
from pybbn.pptc.inferencecontroller import InferenceController
import numpy as np

# Set Pandas options to display more columns
pd.options.display.max_columns=50

# Create sample weather data since the URL is not working
np.random.seed(42)
n_samples = 1000

# Create synthetic weather data
data = {
    'Humidity9am': np.random.randint(30, 100, n_samples),
    'Humidity3pm': np.random.randint(20, 95, n_samples),
    'WindGustSpeed': np.random.randint(30, 80, n_samples),
    'RainTomorrow': np.random.choice(['No', 'Yes'], n_samples, p=[0.7, 0.3])
}

df = pd.DataFrame(data)

# Create bands for variables that we want to use in the model
df['WindGustSpeedCat'] = df['WindGustSpeed'].apply(lambda x: '0.<=40' if x<=40 else '1.40-50' if 40<x<=50 else '2.>50')
df['Humidity9amCat'] = df['Humidity9am'].apply(lambda x: '1.>60' if x>60 else '0.<=60')
df['Humidity3pmCat'] = df['Humidity3pm'].apply(lambda x: '1.>60' if x>60 else '0.<=60')

# Show a snapshot of data
print("First few rows of the dataset:")
print(df.head())
print(f"\nDataset shape: {df.shape}")
print("\nValue counts for RainTomorrow:")
print(df['RainTomorrow'].value_counts())

# This function helps to calculate probability distribution, which goes into BBN (note, can handle up to 2 parents)
def probs(data, child, parent1=None, parent2=None):
    if parent1 is None:
        # Calculate probabilities
        prob = pd.crosstab(data[child], 'Empty', margins=False, normalize='columns').sort_index().to_numpy().reshape(-1).tolist()
    elif parent1 is not None:
        # Check if child node has 1 parent or 2 parents
        if parent2 is None:
            # Calculate probabilities
            prob = pd.crosstab(data[parent1], data[child], margins=False, normalize='index').sort_index().to_numpy().reshape(-1).tolist()
        else:
            # Calculate probabilities
            prob = pd.crosstab([data[parent1], data[parent2]], data[child], margins=False, normalize='index').sort_index().to_numpy().reshape(-1).tolist()
    else: 
        print("Error in Probability Frequency Calculations")
        return []
    return prob

# Create nodes by using our earlier function to automatically calculate probabilities
print("\nCreating BBN nodes...")
H9am = BbnNode(Variable(0, 'H9am', ['<=60', '>60']), probs(df, child='Humidity9amCat'))
H3pm = BbnNode(Variable(1, 'H3pm', ['<=60', '>60']), probs(df, child='Humidity3pmCat', parent1='Humidity9amCat'))
W = BbnNode(Variable(2, 'W', ['<=40', '40-50', '>50']), probs(df, child='WindGustSpeedCat'))
RT = BbnNode(Variable(3, 'RT', ['No', 'Yes']), probs(df, child='RainTomorrow', parent1='Humidity3pmCat', parent2='WindGustSpeedCat'))

# Create Network
print("Building Bayesian Network...")
bbn = Bbn() \
    .add_node(H9am) \
    .add_node(H3pm) \
    .add_node(W) \
    .add_node(RT) \
    .add_edge(Edge(H9am, H3pm, EdgeType.DIRECTED)) \
    .add_edge(Edge(H3pm, RT, EdgeType.DIRECTED)) \
    .add_edge(Edge(W, RT, EdgeType.DIRECTED))

# Convert the BBN to a join tree
print("Creating join tree...")
join_tree = InferenceController.apply(bbn)

# Set node positions
pos = {0: (-1, 2), 1: (-1, 0.5), 2: (1, 0.5), 3: (0, -1)}

# Set options for graph looks
options = {
    "font_size": 16,
    "node_size": 4000,
    "node_color": "white",
    "edgecolors": "black",
    "edge_color": "blue",
    "linewidths": 2,
    "width": 2,
}

# Generate graph
print("Drawing graph...")
n, d = bbn.to_nx_graph()
plt.figure(figsize=(10, 8))
nx.draw(n, with_labels=True, labels=d, pos=pos, **options)

# Update margins and print the graph
ax = plt.gca()
ax.margins(0.10)
plt.axis("off")
plt.title("Bayesian Belief Network for Weather Prediction", size=16)
plt.show()

# Define a function for printing marginal probabilities
def print_probs():
    for node in join_tree.get_bbn_nodes():
        potential = join_tree.get_bbn_potential(node)
        print("Node:", node)
        print("Values:")
        print(potential)
        print('----------------')

# Use the above function to print marginal probabilities
print("\nInitial Marginal Probabilities:")
print_probs()

# To add evidence of events that happened so probability distribution can be recalculated
def evidence(nod, cat, val):
    ev = EvidenceBuilder() \
    .with_node(join_tree.get_bbn_node_by_name(nod)) \
    .with_evidence(cat, val) \
    .build()
    join_tree.set_observation(ev)

# Use above function to add evidence - fixing the evidence function call
print("\nAdding evidence: H9am = '>60'")
evidence('H9am', '>60', 1.0)

# Print marginal probabilities after evidence
print("\nMarginal Probabilities After Evidence:")
print_probs()

# Let's add another evidence example
print("\nAdding evidence: W = '>50'")
evidence('W', '>50', 1.0)

print("\nMarginal Probabilities After Both Evidence:")
print_probs()

# Clear evidence and show original probabilities again
print("\nClearing all evidence...")
join_tree.unobserve_all()

print("\nOriginal Marginal Probabilities (Evidence Cleared):")
print_probs()
