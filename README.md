A continaer image for an IOC using the motorAutomation1 support module.

NOTE:  The container cannot be built by Github CI as it requires access to Aerotech
binaries.

To build the container locally, extract the Aerotech SDK into this directory under
Aerotech_H_SO/, then run `docker build . -t ioc-automation1:dls.run`.
