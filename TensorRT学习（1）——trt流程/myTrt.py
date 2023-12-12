# -*- encoding: utf-8 -*-
'''
@File    :   myTrt.py
@Time    :   2023/12/11 21:07:25
@Author  :   Strive-G 
@Version :   1.0
@Contact :   youwan114@163.com
description : Log output to console
'''

import os

import numpy as np
import tensorrt as trt
from cuda import cudart

trtFile = 'myTrt.plan'

def main():


    # 创新 trt 日志
    logger = trt.Logger(trt.Logger.INFO)                                       # create Logger, avaiable level: VERBOSE, INFO, WARNING, ERRROR, INTERNAL_ERROR
    builder = trt.Builder(logger)                                           # create Builder
    
    network = builder.create_network(1 << int(trt.NetworkDefinitionCreationFlag.EXPLICIT_BATCH))  # create Network
    # network = builder.create_network()  # create Network 创建失败
    profile = builder.create_optimization_profile()                         # create Optimization Profile if using Dynamic Shape mode
    
    
    config = builder.create_builder_config()                                # create BuidlerConfig to set meta data of the network
    config.set_memory_pool_limit(trt.MemoryPoolType.WORKSPACE, 1 << 30)     # set workspace for the optimization process (default value is total GPU memory)

    inputTensor = network.add_input("inputT0", trt.float32, [-1, -1, -1])   # set inpute tensor for the network
    profile.set_shape(inputTensor.name, [1, 1, 1], [3, 4, 5], [6, 8, 10])   # set danamic range of the input tensor
    config.add_optimization_profile(profile)                                # add the Optimization Profile into the BuilderConfig

    identityLayer = network.add_identity(inputTensor)                       # here is only a identity transformation layer in our simple network, which the output is exactly equal to input
    network.mark_output(identityLayer.get_output(0))                        # mark the output tensor of the network

    engineString = builder.build_serialized_network(network, config)    

    if engineString == None:
        print("Failed building serialized engine!")
        return
    print("Succeeded building serialized engine!")
    with open(trtFile, "wb") as f:                                          # write the serialized netwok into a .plan file
        f.write(engineString)
        print("Succeeded saving .plan file!")  

    engine = trt.Runtime(logger).deserialize_cuda_engine(engineString)          # create inference Engine using Runtime
    if engine == None:
        print("Failed building engine!")
        return
    print("Succeeded building engine!")  

    nIO = engine.num_io_tensors  
    lTensorName = [engine.get_tensor_name(i) for i in range(nIO)]               # get a list of I/O tensor names of the engine, because all I/O tensor in Engine and Excution Context are indexed by name, not binding number like TensorRT 8.4 or before
       
    nInput = [engine.get_tensor_mode(lTensorName[i]) for i in range(nIO)].count(trt.TensorIOMode.INPUT)  # get the count of input tensor
    nOutput = [engine.get_tensor_mode(lTensorName[i]) for i in range(nIO)].count(trt.TensorIOMode.OUTPUT)  # get the count of output tensor



    print(nIO)
    print(nInput)
    print(nOutput)
    for i in range(nIO):
        name = engine.get_tensor_name(i)
        print(name)

    context = engine.create_execution_context()                                 # create Excution Context from the engine (analogy to a GPU context, or a CPU process)
    context.set_input_shape(lTensorName[0], [3, 4, 5])                          # set actual size of input tensor if using Dynamic Shape mode

    for i in range(nIO):
        print("[%2d]%s->" % (i, "Input " if i < nInput else "Output"), engine.get_tensor_dtype(lTensorName[i]), engine.get_tensor_shape(lTensorName[i]), context.get_tensor_shape(lTensorName[i]), lTensorName[i])

    bufferH = []                                                                # prepare the memory buffer on host and device
    data = np.arange(3 * 4 * 5, dtype=np.float32).reshape(3, 4, 5) 
    # data = np.arange(3 * 4 * 5, dtype=np.float32)
    print('data ----->', data.shape)

    bufferH.append(np.ascontiguousarray(data))
    print(len(bufferH))
    for i in range(nInput, nIO):
        buffer = np.empty(context.get_tensor_shape(lTensorName[i]), dtype=trt.nptype(engine.get_tensor_dtype(lTensorName[i])))
        bufferH.append(buffer)
        print('buffer H ----------------------' )
        print(buffer.shape)

    print(bufferH[1])
    print(len(bufferH))
    print(trt.nptype(engine.get_tensor_dtype(lTensorName[1])))


    bufferD = []
    for i in range(nIO):
        cuda_memory = cudart.cudaMalloc(bufferH[i].nbytes)[1]
        bufferD.append(cuda_memory)
        print('cuda_memory ====================')
        print(cuda_memory/1e6/32//4, 'MB')

    for i in range(nInput):                                                     # copy input data from host buffer into device buffer
        cudart.cudaMemcpy(bufferD[i], bufferH[i].ctypes.data, bufferH[i].nbytes, cudart.cudaMemcpyKind.cudaMemcpyHostToDevice)

    for i in range(nIO):
        context.set_tensor_address(lTensorName[i], int(bufferD[i]))             # set address of all input and output data in device buffer
        print()

    context.execute_async_v3(0)                                                 # do inference computation

    for i in range(nInput, nIO):                                                # copy output data from device buffer into host buffer
        print('nInput nIO',i)

        cudart.cudaMemcpy(bufferH[i].ctypes.data, bufferD[i], bufferH[i].nbytes, cudart.cudaMemcpyKind.cudaMemcpyDeviceToHost)

    for i in range(nIO):
        print(lTensorName[i])
        print(bufferH[i].shape)
        print(bufferD)

    for b in bufferD:                                                           # free the GPU memory buffer after all work
        cudart.cudaFree(b)


if __name__ == '__main__':
    main()
    print('finish trt test ---------------->')
