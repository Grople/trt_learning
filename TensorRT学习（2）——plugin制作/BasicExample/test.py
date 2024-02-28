import tensorrt as trt




def get_plugin_names(): 
    return [pc.name for pc in trt.get_plugin_registry().plugin_creator_list] 
    
print(get_plugin_names()) 