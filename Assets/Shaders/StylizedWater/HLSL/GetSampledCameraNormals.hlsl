#ifndef SHADERGRAPH_PREVIEW
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
#endif

void GetSampledCameraNormals_float(float2 UV, out float3 SampledCameraNormals)
{
#ifdef SHADERGRAPH_PREVIEW
    SampledCameraNormals =  float3(0.0, 0.0, 1.0);
#else
    float3 sampledNormals = SampleSceneNormals(UV);
    SampledCameraNormals = TransformWorldToViewDir(sampledNormals);
#endif   
}