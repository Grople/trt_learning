/*
 * Copyright (c) 2021-2023, NVIDIA CORPORATION. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "AddScalarPlugin.h"

// kernel for GPU
__global__ void addScalarKernel(const float *input, float *output, const float scalar, const int nElement)
{
    const int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= nElement)
        return;

    float _1      = input[index];
    float _2      = _1 + scalar;
    output[index] = _2;
}

namespace nvinfer1
{
// class AddScalarPlugin
AddScalarPlugin::AddScalarPlugin(const std::string &name, float scalar):
    name_(name)   // C++给自己的成员变量赋值
{
    WHERE_AM_I();
    m_.scalar = scalar;
}

AddScalarPlugin::AddScalarPlugin(const std::string &name, const void *buffer, size_t length):
    name_(name)
{
    WHERE_AM_I();
    memcpy(&m_, buffer, sizeof(m_));    // memcpy: 拷贝内存
                                        // sizeof: 返回所占字节数
}

AddScalarPlugin::~AddScalarPlugin()
{
    WHERE_AM_I();
}

IPluginV2DynamicExt *AddScalarPlugin::clone() const noexcept
{
    WHERE_AM_I();
    auto p = new AddScalarPlugin(name_, &m_, sizeof(m_));
    p->setPluginNamespace(namespace_.c_str());
    return p;
}

int32_t AddScalarPlugin::getNbOutputs() const noexcept
{
    WHERE_AM_I();
    return 1;
}

DataType AddScalarPlugin::getOutputDataType(int32_t index, DataType const *inputTypes, int32_t nbInputs) const noexcept
{
    WHERE_AM_I();
    return inputTypes[0];
}

DimsExprs AddScalarPlugin::getOutputDimensions(int32_t outputIndex, const DimsExprs *inputs, int32_t nbInputs, IExprBuilder &exprBuilder) noexcept
{
    WHERE_AM_I();
    return inputs[0];
}

bool AddScalarPlugin::supportsFormatCombination(int32_t pos, const PluginTensorDesc *inOut, int32_t nbInputs, int32_t nbOutputs) noexcept
{
    WHERE_AM_I();
    bool res;
    switch (pos)
    {
    case 0:
        res = inOut[0].type == DataType::kFLOAT && inOut[0].format == TensorFormat::kLINEAR;
        break;
    case 1:
        res = inOut[1].type == inOut[0].type && inOut[1].format == inOut[0].format;
        break;
    default: // should NOT be here!
        res = false;
    }
#ifdef DEBUG
    std::cout << "\tpos=" << pos << ",res=" << res << "->[";
    for (int i = 0; i < nbInputs + nbOutputs; ++i)
    {
        std::cout << formatToString(inOut[i].format) << ",";
    }
    std::cout << "],[";
    for (int i = 0; i < nbInputs + nbOutputs; ++i)
    {
        std::cout << dataTypeToString(inOut[i].type) << ",";
    }
    std::cout << "]" << std::endl;
#endif
    return res;
}

void AddScalarPlugin::configurePlugin(const DynamicPluginTensorDesc *in, int32_t nbInputs, const DynamicPluginTensorDesc *out, int32_t nbOutputs) noexcept
{
    WHERE_AM_I();
    return;
}

size_t AddScalarPlugin::getWorkspaceSize(const PluginTensorDesc *inputs, int32_t nbInputs, const PluginTensorDesc *outputs, int32_t nbOutputs) const noexcept
{
    WHERE_AM_I();
    return 0;
}

int32_t AddScalarPlugin::enqueue(const PluginTensorDesc *inputDesc, const PluginTensorDesc *outputDesc, const void *const *inputs, void *const *outputs, void *workspace, cudaStream_t stream) noexcept
{
    WHERE_AM_I();
    int nElement = 1;
    for (int i = 0; i < inputDesc[0].dims.nbDims; ++i)
    {
        nElement *= inputDesc[0].dims.d[i];
    }
    dim3 grid(CEIL_DIVIDE(nElement, 256), 1, 1),   block(256, 1, 1);

    //   Kernel<<<Dg,Db, Ns, S>>>(param list);
    //  gird, block,  
    //  Ns:  用于设置每个block除了静态分配的shared Memory以外，最多能动态分配的shared memory大小，单位为byte。不需要动态分配时该值为0或省略不写。
    //  S:   cudaStream_t类型的可选参数，初始值为零，表示该核函数处在哪个流之中
    addScalarKernel<<<grid, block, 0, stream>>>( reinterpret_cast<const float *>(inputs[0]), reinterpret_cast<float *>(outputs[0]), m_.scalar, nElement);
    return 0;
}

void AddScalarPlugin::destroy() noexcept
{
    WHERE_AM_I();
    delete this;
    return;
}

int32_t AddScalarPlugin::initialize() noexcept
{
    WHERE_AM_I();
    return 0;
}

void AddScalarPlugin::terminate() noexcept
{
    WHERE_AM_I();
    return;
}

size_t AddScalarPlugin::getSerializationSize() const noexcept
{
    WHERE_AM_I();
    return sizeof(m_);
}

void AddScalarPlugin::serialize(void *buffer) const noexcept
{
    WHERE_AM_I();
    memcpy(buffer, &m_, sizeof(m_));
    return;
}

void AddScalarPlugin::setPluginNamespace(const char *pluginNamespace) noexcept
{
    WHERE_AM_I();
    namespace_ = pluginNamespace;
    return;
}

const char *AddScalarPlugin::getPluginNamespace() const noexcept
{
    WHERE_AM_I();
    return namespace_.c_str();
}

const char *AddScalarPlugin::getPluginType() const noexcept
{
    WHERE_AM_I();
    return PLUGIN_NAME;
}

const char *AddScalarPlugin::getPluginVersion() const noexcept
{
    WHERE_AM_I();
    return PLUGIN_VERSION;
}

void AddScalarPlugin::attachToContext(cudnnContext *contextCudnn, cublasContext *contextCublas, IGpuAllocator *gpuAllocator) noexcept
{
    WHERE_AM_I();
    return;
}

void AddScalarPlugin::detachFromContext() noexcept
{
    WHERE_AM_I();
    return;
}

// class AddScalarPluginCreator
PluginFieldCollection    AddScalarPluginCreator::fc_ {};    // 初始化成员变量        PluginFieldCollection  fc_；
std::vector<PluginField> AddScalarPluginCreator::attr_;     // vector< > 指定类型的 list

AddScalarPluginCreator::AddScalarPluginCreator()
{
    WHERE_AM_I();
    attr_.clear();
    attr_.emplace_back(PluginField("scalar", nullptr, PluginFieldType::kFLOAT32, 1));    //  vector.emplace_back  在末尾添加一个元素
    fc_.nbFields = attr_.size();
    fc_.fields   = attr_.data();    // vector.data 返回vector所有元素，是一个数组类型
}

AddScalarPluginCreator::~AddScalarPluginCreator()
{
    WHERE_AM_I();
}

IPluginV2DynamicExt *AddScalarPluginCreator::createPlugin(const char *name, const PluginFieldCollection *fc) noexcept
{
    WHERE_AM_I();
    float                          scalar = 0;
    std::map<std::string, float *> parameterMap {{"scalar", &scalar}};

    for (int i = 0; i < fc->nbFields; ++i)
    {
        if (parameterMap.find(fc->fields[i].name) != parameterMap.end())
        {
            *parameterMap[fc->fields[i].name] = *reinterpret_cast<const float *>(fc->fields[i].data);
        }
    }
    AddScalarPlugin *pObj = new AddScalarPlugin(name, scalar);
    pObj->setPluginNamespace(namespace_.c_str());
    return pObj;
}

IPluginV2DynamicExt *AddScalarPluginCreator::deserializePlugin(const char *name, const void *serialData, size_t serialLength) noexcept
{
    WHERE_AM_I();
    AddScalarPlugin *pObj = new AddScalarPlugin(name, serialData, serialLength);
    pObj->setPluginNamespace(namespace_.c_str());
    return pObj;
}

void AddScalarPluginCreator::setPluginNamespace(const char *pluginNamespace) noexcept
{
    WHERE_AM_I();
    namespace_ = pluginNamespace;
    return;
}

const char *AddScalarPluginCreator::getPluginNamespace() const noexcept
{
    WHERE_AM_I();
    return namespace_.c_str();
}

const char *AddScalarPluginCreator::getPluginName() const noexcept
{
    WHERE_AM_I();
    return PLUGIN_NAME;
}

const char *AddScalarPluginCreator::getPluginVersion() const noexcept
{
    WHERE_AM_I();
    return PLUGIN_VERSION;
}

const PluginFieldCollection *AddScalarPluginCreator::getFieldNames() noexcept
{
    WHERE_AM_I();
    return &fc_;
}

REGISTER_TENSORRT_PLUGIN(AddScalarPluginCreator);

} // namespace nvinfer1
