# RIPPLELAB
[![Project Status: Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](https://www.repostatus.org/badges/latest/inactive.svg)](https://www.repostatus.org/#inactive)
![Licence](https://img.shields.io/github/license/mnavarretem/RIPPLELAB)

RIPPLELAB is a multi-window GUI developed in MATLAB for the analysis of high frequency oscillations

This is the RIPPLELAB main folder. It contains folders and functions for
RIPPLELAB Multi Analysis EEG Project . 

A computing platform for processing continuous local field potentials
(LFP). The interface, additional to implement different documented 
algorithms for HFO detection, it provides several tools for signal 
visualization and manipulation, among which are found:
 - Channel(s) selection.
 - Display of multiple signal at the same time.
 - Several zoom and grid options (time, amplitude, etc.)
 - Possibility to make time and amplitude measurements directly on the 
 signals.
 - Adjustable filter options (notch, band-pass, etc.)

## Installation
Get the source code available at https://github.com/BSP-Uniandes/RIPPLELAB/

Add RIPPLELAB's files to the MATLAB path: [Home > Set Path > Add with subfolders]

or typing in the command window:
``` Matlab
addpath(genpath(c:/~your-ripplelab-basefolder));
```

## Usage
If RIPPLELAB files are in the MATLAB path, write the script name on the workspace
``` Matlab
p_RippleLab
```

## Support
We encourage to report any issues at https://github.com/mnavarretem/RIPPLELAB/issues

Nevertheless, any questions and suggestions can be addressed to:
Miguel Navarrete (mnavarretem@gmail.com) or Mario Valderrama (mvalderm@gmail.com)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Project status
Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.

## Authors

* **Miguel Navarrete** - *Initial work* - [mnavarretem](https://github.com/mnavarretem)

## Licence
[GNU-GPLv3] https://www.gnu.org/licenses/gpl-3.0.html
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Copyright (C) 2011-2013, Department of Electrical and Electronic Engineering, Universidad de los Andes, Colombia
Copyright (C) 2013-2015, Department of Biomedical Engineering, Universidad de los Andes, Colombia
