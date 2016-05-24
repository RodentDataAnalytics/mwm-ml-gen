# mwm-ml-gen
This program is the generalised version of mwm-ml (https://github.com/RodentDataAnalytics/mwm-ml). For more information on the experimental setups
and the procedures refer to the published paper http://www.nature.com/articles/srep14562.

## The Graphical User Interface (GUI)
The graphical user interface is split into two separate interfaces: the gui.m and the browse_trajectories.m. The first one is the main
interface where the user specifies the experimental setup and performs the segmentation and the classification processes while the other acts as a graphical tool for labelling the trajectories segments.

### gui.m
![GUI](gui.jpg?raw=true "GUI")

**Paths and Files Format:**

• *Trajectory Raw Data:* requires a folder containing the Ethovision's exported CSV files.  

• *Output Folder:* path in which the results will be saved.

• *Fields:* specify which fields contains the following information: animal id, animal group, trial number, recorded time, X & Y coordinates. Note: if the animal group is not available inside the CSV file the user can create a custom CSV which will contain each animal id and the group in which it bolongs to. If neither the field nor the csv are specified then it will assumed that all the animals belong to the same group (default group 1).

**Experiment Settings:**

• *Sessions:* number of sessions

• *Trials per Session:* must be given in the following format: num1,num2,...,numN, where N = number of sessions (example: 4,4,4).

**Save Settings:**

Saves the above settings into a MAT file.

**Load Settings:**

Loads the above settings from a MAT file.

**Segmentation:**

• *Segment Length:* length of the segments.

• *Segment Overlap:* overlap of the segments.

• *Segmentation Button:* If all the above inputs are given (validation is performed and in case of error appropriate error messages appear to the user), the program loads the trajectory data, performs the segmentation process and computes the features of the trajectories and the trajectories' segments. All the results are stored inside a MAT file (segmentation_configs) which is saved in the speficied output path.

**Labelling and Classification:**

• *Labels:* requires a CSV file which contains labelled segments (see browse_trajectories.m, **Save Labels** button). Three of 
these files are provided inside the .\import\original_data\mwm_peripubertal_stress\ folder, (a) segment_labels_250_90.csv (b) segment_labels_250_70.csv (c) segment_labels_300_70.csv.

• *Segment Configurations:* requires a MAT file generated from the segmentation process.

• *Number of Clusters:* number of clusters that will be used during the first clustering stage.

• *Classify Button:* If all the above inputs are given (validation is performed and in case of error appropriate error messages appear to the user), the program performs classification of the segments. The classification results are stored inside a MAT file (classification_configs) which is saved in the speficied output path.

**Results:**

• *Published Results:* accepts 1-3 as an input and it is used to generate the original published results (refer to http://www.nature.com/articles/srep14562). In order to generate the results of the original code use the option 3. The generated MAT files and figures are saved inside the generated .\cache folder.

• *Animal Metrics:* requires a segmentation_configs object and visualize the trajectory metrics of the animal groups over all the trials. It can visualize up to two animal groups specified by the user (examples: 2 or 2,3). Note if the data contain no animal groups then the animal group is not required to be specified.

• *Class Performance:* requires a segmentation_configs object and generates three figures indicating the impact of the number of clusters on the clustering performance for a set of N computed segments: Figure1 - Percentage of classification errors. Figure2 - Percentage of segments belonging to clusters that could not be mapped unambiguously to a single class. Figure3 - Percentage of the full swimming paths that are covered by at least one segment of a known class. It may be used in order to find the optimal numbers of clusters for the classification procedure.

• *Strategies:* requires a segmentation_configs and a classification_configs objects in order to compute the average segment lengths for each strategy adopted by one or two groups (specified by the user, same as **Animal Metrics**) of N animals for a set of M trials. The generated plots show the average length in meters that the animals spent in one strategy during each trial.

• *Transitions:* requires a segmentation_configs and a classification_configs objects in order to compute and present the number of transitions between strategies for one or two groups (specified by the user, same as **Animal Metrics**) of N animals.

• *Trans Probabilities:* requires a segmentation_configs and a classification_configs objects in order to compute and present the transition probabilities of strategies within all the trials for one or two groups (specified by the user, same as **Animal Metrics**) of N animals. Rows and columns indicate the starting and ending strategies respectively. Row values are normalised.

• *Confusion Matrix:* requires a segmentation_configs and a classification_configs objects in order to computes the confusion matrix for the classification of segments. Values are the total number of missclassifications for a 10-fold cross-validation of the clustering algorithm.

**Browse Trajectories:**

Loads the browse_trajectories gui. 

**Exit:**

Exits the GUI

### browse_trajectories.m
![BROWSE](browse_trajectories.jpg?raw=true "BROWSE")

This file opens the interface which is used for the labelling of specific segments. It can be loaded by typing browse_trajectories or by clicking on the Browse Trajectories button of the gui.m.

First of all a segmentation configuation file (created from the segmentation process) must be given by clicking on the button
**Select Configuration File**. When the file is loaded, the user can see the arena with the whole trajectories as well as 
their segments. Below the arena the navigation panel allows the user to navigate to the previous (**<=**) or the 
next trajectory (**=>**) or specify which trajectory to be visualized by typing its id number and clicking **OK**.

The two tables on the upper left part of the window show various information about the selected trajectory and the
selected segment of the trajectory.

The **Segments** panel is used for manually labelling each of the segments. In order to label a segment this segment must be
selected from the list of segments and the desired label must be selected from the dropdown menu. Afterwards the button **+** must
be pressed. In order to remove a label from a segment the same process must be followed but afterwards the button **-** must
be pressed. Multiple labels can be assigned per segment and these assigned labels are shown on the square box.

The button **Save Labels** is used to save all the labelled segments and generates the CSV file required for the classification process.

The button **Load Labels File** asks for a CSV file which contains labelled segments. These files are generated by the button **Save Labels**.
