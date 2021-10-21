TOP = ../..
include $(TOP)/configure/CONFIG

PROD_IOC = ioc
DBD += ioc.dbd
ioc_DBD += base.dbd
ioc_DBD += asyn.dbd
ioc_DBD += drvAsynSerialPort.dbd
ioc_DBD += drvAsynIPPort.dbd
ioc_DBD += busySupport.dbd
ioc_DBD += motorSupport.dbd
ioc_DBD += devSoftMotor.dbd
ioc_DBD += devAutomation1Motor.dbd

# TODO(tri): Do we need these?
ioc_DBD += devIocStats.dbd
ioc_DBD += asSupport.dbd

ioc_SRCS += ioc_registerRecordDeviceDriver.cpp

ioc_LIBS += busy
ioc_LIBS += asyn
ioc_LIBS += softMotor
ioc_LIBS += motor
ioc_LIBS += Automation1

automation1compiler_DIR += $(MOTOR_AUTOMATION1)/automation1Sup/Lib
ioc_LIBS += automation1compiler
automation1c_DIR += $(MOTOR_AUTOMATION1)/automation1Sup/Lib
ioc_LIBS += automation1c

# TODO(tri): Do we need these?
ioc_LIBS += devIocStats
ioc_LIBS += autosave

ioc_LIBS += $(EPICS_BASE_IOC_LIBS)


ioc_SRCS += iocMain.cpp

## TODO add system libraries
# ioc_SYS_LIBS += aravis-0.8

include $(TOP)/configure/RULES
