OpenPIV Proper Orthogonal Decomposition (POD) Toolbox
=====================================================

Proper Orthogonal Decomposition (POD) or Principal Component Analysis (PCA) http://en.wikipedia.org/wiki/Principal_component_analysis is an objective method to extract the most energetic structures from numerical or experimental data, in our case of fluid mechanics. The toolbox was originally developed by the OpenPIV group for the use with the Matlab (tm) version of OpenPIV in 2000, then for the use with Insight (tm) software by TSI Inc. (www.tsi.com). At present it can read the PIV data from OpenPIV (TXT ASCII files), Insight (VEC format) or OpenPIV Spatial Toolbox MAT files. The toolbox can estimate the POD modes using direct or snapshots method and it provides an extra layer of fluid dynamics insight using the linear combination of the POD modes, enabling the coherent structures detection and characterization. For the details, see the article listed below.


How to obtain the toolbox
-------------------------

Use Github repository if you wish to develop the toolbox further or download the ZIP file of the recent branch to get the repository copy without Git. 


How to use the toolbox
----------------------

Open Matlab, add the toolbox to the path using ```addpath''' or the graphical interface or simply change the folder to the POD Toolbox folder. Type:

    >> podbox 
    
The directory includes the folder ```/test''' with a small set of VEC files. Please follow the detailed Getting Started manual in the ```/docs''' directory




How to cite this toolbox
------------------------

Use Bibtex:



    @article{Gurka2006416,
    title = "\{POD\} of vorticity fields: A method for spatial characterization of coherent structures ",
    journal = "International Journal of Heat and Fluid Flow ",
    volume = "27",
    number = "3",
    pages = "416 - 423",
    year = "2006",
    note = "",
    issn = "0142-727X",
    doi = "http://dx.doi.org/10.1016/j.ijheatfluidflow.2006.01.001",
    url = "http://www.sciencedirect.com/science/article/pii/S0142727X06000026",
    author = "Roi Gurka and Alexander Liberzon and Gad Hetsroni",
    keywords = "Boundary layer",
    keywords = "Vorticity",
    keywords = "Proper orthogonal decomposition",
    keywords = "Coherent structures",
    keywords = "Identification ",
    abstract = "We present a method to identify large scale coherent structures, in turbulent flows, and characterize them. The method is based on the linear combination of the proper orthogonal decomposition (POD) modes of vorticity. Spanwise vorticity is derived from the two-dimensional and two-component velocity fields measured by means of particle image velocimetry (PIV) in the streamwise–wall normal plane of a fully developed turbulent boundary layer in a flume. The identification method makes use of the whole data set simultaneously, through the two-point correlation tensor, providing a statistical description of the dominant coherent motions in a turbulent boundary layer. The identified pattern resembles an elongated, quasi-streamwise, vortical structure with streamwise length equal to the water height in the flume and inclined upwards in the streamwise–wall normal plane at angle of approximately 8°. "
    }


