#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_SCREEN

#pragma multi_compile _ _ADDITIONAL_LIGHTS
#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

#ifndef TOON_SHADING_FUNCTIONS
#define TOON_SHADING_FUNCTIONS

#ifndef SHADERGRAPH_PREVIEW
struct SurfaceVariables
{
    float3 normal;
    float lightingBands;
    float lightingBandsBias;
    float lightingLiftFactor;
    float darkSideMinimumLightMultiplier;
};
    
float PlaceLightingInBand(float Lighting, float LightingBands, float LightingBandsBias, float LightingLiftFactor)
{
    LightingBands = max(LightingBands, 1.0);  
    LightingLiftFactor = max(LightingLiftFactor, 1.0);
    
    float floorValue = floor(Lighting * LightingBands) / LightingBands;
    float ceilValue = ceil(Lighting * LightingBands) / LightingBands;
    
    float bandedLighting = lerp(floorValue, ceilValue, LightingBandsBias);
    
    bandedLighting = saturate(bandedLighting * LightingLiftFactor);
   
    return bandedLighting;
}

float3 CalculateToonShading(Light l, SurfaceVariables s, float DarkSideMinimumLightMultiplier)
{
    float diffuse = saturate(dot(s.normal, l.direction));
    float attenuation = l.distanceAttenuation * l.shadowAttenuation;  
    
    attenuation = saturate(attenuation); 
    diffuse *= attenuation;  
    
    float bandedLighting = PlaceLightingInBand(diffuse, s.lightingBands, s.lightingBandsBias, s.lightingLiftFactor);
    
    float darkSideMask = diffuse <= 0;
    float lowestBandedLighting = PlaceLightingInBand(0.00001f, s.lightingBands, s.lightingBandsBias, s.lightingLiftFactor);
    
    bandedLighting = lerp(bandedLighting, lowestBandedLighting * DarkSideMinimumLightMultiplier, darkSideMask);
    
    return l.color * bandedLighting;
}
#endif

void LightingToonShaded_float(
    float3 Position,
    float3 Normal,
    float LightingBands,
    float LightingBandsBias,
    float LightingLiftFactor,
    float DarkSideMinimumLightMultiplier,
    out float3 Color
)
{
#if defined(SHADERGRAPH_PREVIEW)
    Color = float3(0.5f,0.5f,0.5f);
#else
    SurfaceVariables s;
    s.normal = normalize(Normal);
    s.lightingBands = LightingBands;
    s.lightingBandsBias = LightingBandsBias;
    s.lightingLiftFactor = LightingLiftFactor;
    
    Color = float3(0.0f, 0.0f, 0.0f);
    
    #if defined (_USEMAINLIGHT)
        Light mainLight;
        
        #if defined (_USEMAINLIGHTSHADOWS)
            #if defined(_MAIN_LIGHT_SHADOWS_SCREEN)
                float4 shadowCoord = ComputeScreenPos(TransformWorldToHClip(Position));
            #else 
                float4 shadowCoord = TransformWorldToShadowCoord(Position);
            #endif
            
            mainLight = GetMainLight(shadowCoord);
        #else
            mainLight = GetMainLight();
        #endif
        
        Color += CalculateToonShading(mainLight, s, DarkSideMinimumLightMultiplier);
    
#endif
    
    #if defined(_USEADDITIONALLIGHTS) && defined(_ADDITIONAL_LIGHTS)

    int pixelLightCount = GetAdditionalLightsCount();

    for (int i = 0; i < pixelLightCount; i++)
    {
        #if defined(_USEADDITIONALLIGHTSSHADOWS) && defined(_ADDITIONAL_LIGHT_SHADOWS)
            Light additionalLight = GetAdditionalLight(i, Position, 1);
        #else
            Light additionalLight = GetAdditionalLight(i, Position);
        #endif

        
        Color += CalculateToonShading(additionalLight, s, 0);
    }

#endif
#endif
}
#endif