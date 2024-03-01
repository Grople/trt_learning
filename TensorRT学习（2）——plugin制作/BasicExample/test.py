import tensorrt as trt

import ctypes
import numpy as np


def get_plugin_names(): 
    return [pc.name for pc in trt.get_plugin_registry().plugin_creator_list] 
    

def getAddScalarPlugin(scalar):
    for c in trt.get_plugin_registry().plugin_creator_list:    #  
        #print(c.name)
        if c.name == "AddScalar":
            parameterList = []
            parameterList.append(trt.PluginField("scalar", np.float32(scalar), trt.PluginFieldType.FLOAT32))

            plugin_ = trt.PluginFieldCollection(parameterList)


            # print(plugin_.nbFields)
            print(dir(plugin_))
            # print(dir(plugin_[0]))
            print(plugin_[0].name)
            print(plugin_[0].data)
            print(plugin_[0].size)
            print(plugin_[0].type)

            print('----------')
            field_names = c.field_names
            print(dir(field_names))
            for name in field_names:
                print(name.name)
                print(name.data)
                print(name.type)
                print(name.size)


            return c.create_plugin(c.name, plugin_ )
    return None


logger = trt.Logger(trt.Logger.ERROR)   

soFile = './AddScalarPlugin.so'
trt.init_libnvinfer_plugins(logger, '')
ctypes.cdll.LoadLibrary(soFile)

plugin_ = getAddScalarPlugin(5)
# print(plugin_)
# print(get_plugin_names()) 