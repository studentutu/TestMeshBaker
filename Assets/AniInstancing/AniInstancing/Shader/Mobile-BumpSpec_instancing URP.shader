// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Simplified Bumped Specular shader. Differences from regular Bumped Specular one:
// - no Main Color nor Specular Color
// - specular lighting directions are approximated per vertex
// - writes zero to alpha channel
// - Normalmap uses Tiling/Offset of the Base texture
// - no Deferred Lighting support
// - no Lightmap support
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "AnimationInstancing/Mobile URP Bumped Specular_instancing" 
{
	Properties 
	{
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		
		// Specular vs Metallic workflow
		[HideInInspector] _WorkflowMode("WorkflowMode", Float) = 1.0

		[MainColor][HideInInspector] _BaseColor("Color", Color) = (0.5,0.5,0.5,1)
		[MainTexture][HideInInspector] _BaseMap("Albedo", 2D) = "white" {}

		[HideInInspector]_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		[HideInInspector]_Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
		[HideInInspector]_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
		[HideInInspector]_SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

		[Gamma][HideInInspector] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		[HideInInspector]_MetallicGlossMap("Metallic", 2D) = "white" {}

		[HideInInspector]_SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
		[HideInInspector]_SpecGlossMap("Specular", 2D) = "white" {}

		[HideInInspector][ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[HideInInspector][ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0

		[HideInInspector]_BumpScale("Scale", Float) = 1.0
		[HideInInspector]_BumpMap("Normal Map", 2D) = "bump" {}

		[HideInInspector]_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		[HideInInspector]_OcclusionMap("Occlusion", 2D) = "white" {}

		[HDR][HideInInspector]_EmissionColor("Color", Color) = (0,0,0)
		[HideInInspector]_EmissionMap("Emission", 2D) = "white" {}

		// Blending state
		[HideInInspector] _Surface("__surface", Float) = 0.0
		[HideInInspector] _Blend("__blend", Float) = 0.0
		[HideInInspector] _AlphaClip("__clip", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
		[HideInInspector] _Cull("__cull", Float) = 2.0

		[HideInInspector]_ReceiveShadows("Receive Shadows", Float) = 1.0
		// Editmode props
		[HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

		// ObsoleteProperties
		[HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
		[HideInInspector] _Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
		[HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
		[HideInInspector] _Glossiness("Smoothness", Float) = 0.0
		[HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

	}
	SubShader 
	{ 
		Tags 
		{ 
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Opaque"
			"Queue"="Geometry+0"
			"PreviewType" = "Plane"
		}
		Pass
		{
			Tags 
			{ 
				"LightMode" = "UniversalForward"
			}
			LOD 250
			
			// Render State
			// Blend One Zero, One Zero
			Cull Back
			ZTest LEqual
			ZWrite On
			// Lighting Off
			// ColorMask: <None>
			
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			// Pragmas
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			#pragma fragmentoption ARB_precision_hint_fastest

			// Keywords
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			// Defines
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_POSITION_WS 
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
			#define VARYINGS_NEED_VIEWDIRECTION_WS
			#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
			#define SHADERPASS_FORWARD
			//DECLARE_VERTEX_SKINNING

			// Includes
			#include "AnimationInstancingBaseURP.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
			

			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMap_ST;
			half4 _BaseColor;
			half4 _SpecColor;
			half4 _EmissionColor;
			half _Cutoff;
			half _Smoothness;
			half _Metallic;
			half _BumpScale;
			half _OcclusionStrength;
			CBUFFER_END
			
			// Graph Functions
			// GraphFunctions: <None>
			
			// Graph Vertex
			// GraphVertex: <None>
			
			// Graph Pixel
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
			};
			
			struct SurfaceDescription
			{
				float3 Albedo;
				float3 Normal;
				float3 Emission;
				float Metallic;
				float Smoothness;
				float Occlusion;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				surface.Albedo = IsGammaSpace() ? float3(0.7353569, 0.7353569, 0.7353569) : SRGBToLinear(float3(0.7353569, 0.7353569, 0.7353569));
				surface.Normal = IN.TangentSpaceNormal;
				surface.Emission = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
				surface.Metallic = 0;
				surface.Smoothness = 0.5;
				surface.Occlusion = 1;
				surface.Alpha = 1;
				surface.AlphaClipThreshold = 0;
				return surface;
			}
			
			// --------------------------------------------------
			// Structs and Packing
			
			// Generated Type: Attributes
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv1 : TEXCOORD1;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			
			// Generated Type: Varyings
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float3 positionWS;
				float3 normalWS;
				float4 tangentWS;
				float3 viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					float2 lightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					float3 sh;
				#endif
				float4 fogFactorAndVertexLight;
				float4 shadowCoord;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Generated Type: PackedVaryings
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				#if defined(LIGHTMAP_ON)
				#endif
				#if !defined(LIGHTMAP_ON)
				#endif
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				float3 interp00 : TEXCOORD0;
				float3 interp01 : TEXCOORD1;
				float4 interp02 : TEXCOORD2;
				float3 interp03 : TEXCOORD3;
				float2 interp04 : TEXCOORD4;
				float3 interp05 : TEXCOORD5;
				float4 interp06 : TEXCOORD6;
				float4 interp07 : TEXCOORD7;
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Packed Type: Varyings
			PackedVaryings PackVaryings(Varyings input)
			{
				PackedVaryings output = (PackedVaryings)0;
				output.positionCS = input.positionCS;
				output.interp00.xyz = input.positionWS;
				output.interp01.xyz = input.normalWS;
				output.interp02.xyzw = input.tangentWS;
				output.interp03.xyz = input.viewDirectionWS;
				#if defined(LIGHTMAP_ON)
					output.interp04.xy = input.lightmapUV;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.interp05.xyz = input.sh;
				#endif
				output.interp06.xyzw = input.fogFactorAndVertexLight;
				output.interp07.xyzw = input.shadowCoord;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// Unpacked Type: Varyings
			Varyings UnpackVaryings(PackedVaryings input)
			{
				Varyings output = (Varyings)0;
				output.positionCS = input.positionCS;
				output.positionWS = input.interp00.xyz;
				output.normalWS = input.interp01.xyz;
				output.tangentWS = input.interp02.xyzw;
				output.viewDirectionWS = input.interp03.xyz;
				#if defined(LIGHTMAP_ON)
					output.lightmapUV = input.interp04.xy;
				#endif
				#if !defined(LIGHTMAP_ON)
					output.sh = input.interp05.xyz;
				#endif
				output.fogFactorAndVertexLight = input.interp06.xyzw;
				output.shadowCoord = input.interp07.xyzw;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// --------------------------------------------------
			// Build Graph Inputs
			
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				
				
				output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
				
				
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
			
			ENDHLSL
		}
		//FallBack "Mobile/VertexLit"
		

		// ShadowCaster
		Pass
		{
			Name "ShadowCaster"
			Tags 
			{ 
				"LightMode" = "ShadowCaster"
			}
			
			// Render State
			Blend One Zero, One Zero
			Cull Back
			ZTest LEqual
			ZWrite On
			// ColorMask: <None>
			
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			// Pragmas
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0
			#pragma multi_compile_instancing
			
			// Keywords
			// PassKeywords: <None>
			// GraphKeywords: <None>
			
			// Defines
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS_SHADOWCASTER
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
			CBUFFER_END
			
			// Graph Functions
			// GraphFunctions: <None>
			
			// Graph Vertex
			// GraphVertex: <None>
			
			// Graph Pixel
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
			};
			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				surface.Alpha = 1;
				surface.AlphaClipThreshold = 0;
				return surface;
			}
			
			// --------------------------------------------------
			// Structs and Packing
			
			// Generated Type: Attributes
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			
			// Generated Type: Varyings
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Generated Type: PackedVaryings
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Packed Type: Varyings
			PackedVaryings PackVaryings(Varyings input)
			{
				PackedVaryings output = (PackedVaryings)0;
				output.positionCS = input.positionCS;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// Unpacked Type: Varyings
			Varyings UnpackVaryings(PackedVaryings input)
			{
				Varyings output = (Varyings)0;
				output.positionCS = input.positionCS;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// --------------------------------------------------
			// Build Graph Inputs
			
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				
				
				output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
				
				
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
			
			ENDHLSL
		}
		
		// Depth Only
		Pass
		{
			Name "DepthOnly"
			Tags 
			{ 
				"LightMode" = "DepthOnly"
			}
			
			// Render State
			Blend One Zero, One Zero
			Cull Back
			ZTest LEqual
			ZWrite On
			ColorMask 0
			
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			// Pragmas
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0
			#pragma multi_compile_instancing
			
			// Keywords
			// PassKeywords: <None>
			// GraphKeywords: <None>
			
			// Defines
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS_DEPTHONLY
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
			CBUFFER_END
			
			// Graph Functions
			// GraphFunctions: <None>
			
			// Graph Vertex
			// GraphVertex: <None>
			
			// Graph Pixel
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
			};
			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				surface.Alpha = 1;
				surface.AlphaClipThreshold = 0;
				return surface;
			}
			
			// --------------------------------------------------
			// Structs and Packing
			
			// Generated Type: Attributes
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			
			// Generated Type: Varyings
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Generated Type: PackedVaryings
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Packed Type: Varyings
			PackedVaryings PackVaryings(Varyings input)
			{
				PackedVaryings output = (PackedVaryings)0;
				output.positionCS = input.positionCS;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// Unpacked Type: Varyings
			Varyings UnpackVaryings(PackedVaryings input)
			{
				Varyings output = (Varyings)0;
				output.positionCS = input.positionCS;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// --------------------------------------------------
			// Build Graph Inputs
			
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				
				
				output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
				
				
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
			
			ENDHLSL
		}
		
		// Meta - LighMaps
		Pass
		{
			Name "Meta"
			Tags 
			{ 
				"LightMode" = "Meta"
			}
			
			// Render State
			Blend One Zero, One Zero
			Cull Back
			ZTest LEqual
			ZWrite On
			// ColorMask: <None>
			
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			// Debug
			// <None>
			
			// --------------------------------------------------
			// Pass
			
			// Pragmas
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0
			
			// Keywords
			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			// GraphKeywords: <None>
			
			// Defines
			#define _NORMAL_DROPOFF_TS 1
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define ATTRIBUTES_NEED_TEXCOORD2
			#define SHADERPASS_META
			
			// Includes
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
			
			// --------------------------------------------------
			// Graph
			
			// Graph Properties
			CBUFFER_START(UnityPerMaterial)
			CBUFFER_END
			
			// Graph Functions
			// GraphFunctions: <None>
			
			// Graph Vertex
			// GraphVertex: <None>
			
			// Graph Pixel
			struct SurfaceDescriptionInputs
			{
				float3 TangentSpaceNormal;
			};
			
			struct SurfaceDescription
			{
				float3 Albedo;
				float3 Emission;
				float Alpha;
				float AlphaClipThreshold;
			};
			
			SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
			{
				SurfaceDescription surface = (SurfaceDescription)0;
				surface.Albedo = IsGammaSpace() ? float3(0.7353569, 0.7353569, 0.7353569) : SRGBToLinear(float3(0.7353569, 0.7353569, 0.7353569));
				surface.Emission = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
				surface.Alpha = 1;
				surface.AlphaClipThreshold = 0;
				return surface;
			}
			
			// --------------------------------------------------
			// Structs and Packing
			
			// Generated Type: Attributes
			struct Attributes
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
				#endif
			};
			
			// Generated Type: Varyings
			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Generated Type: PackedVaryings
			struct PackedVaryings
			{
				float4 positionCS : SV_POSITION;
				#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : CUSTOM_INSTANCE_ID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
				#endif
			};
			
			// Packed Type: Varyings
			PackedVaryings PackVaryings(Varyings input)
			{
				PackedVaryings output = (PackedVaryings)0;
				output.positionCS = input.positionCS;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// Unpacked Type: Varyings
			Varyings UnpackVaryings(PackedVaryings input)
			{
				Varyings output = (Varyings)0;
				output.positionCS = input.positionCS;
				#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.instanceID;
				#endif
				#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
					output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
				#endif
				#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
					output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
				#endif
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					output.cullFace = input.cullFace;
				#endif
				return output;
			}
			
			// --------------------------------------------------
			// Build Graph Inputs
			
			SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
			{
				SurfaceDescriptionInputs output;
				ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
				
				
				
				output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
				
				
				#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
				#else
					#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				#endif
				#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
				
				return output;
			}
			
			
			// --------------------------------------------------
			// Main
			
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
			
			ENDHLSL
		}
	}
	CustomEditor "AnimationInstancing.ShaderGui.LitShader"
	FallBack "Hidden/Shader Graph/FallbackError"
}