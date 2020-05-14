using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Instancetest : MonoBehaviour
{
    [SerializeField] private Mesh meshToUse = null;
    [SerializeField] private Material material = null;
    [SerializeField] private Transform[] transfromsToMatrices = new Transform[2];
    private Matrix4x4[] workingMatrixes = null;
    private bool UseInstancing;

    // Update is called once per frame

    private void Awake()
    {
        if (SystemInfo.graphicsDeviceType == UnityEngine.Rendering.GraphicsDeviceType.OpenGLES2)
        {
            UseInstancing = false;
        }
    }
    void Update()
    {
        if (workingMatrixes == null)
        {
            workingMatrixes = new Matrix4x4[transfromsToMatrices.Length];
        }
        for (int i = 0; i < transfromsToMatrices.Length; i++)
        {
            workingMatrixes[i] = Matrix4x4.TRS(transfromsToMatrices[i].position, transfromsToMatrices[i].rotation, transfromsToMatrices[i].lossyScale);
        }
        if (UseInstancing)
        {
            Graphics.DrawMeshInstanced(meshToUse,
                                        0,
                                        material,
                                        workingMatrixes,
                                        transfromsToMatrices.Length);
        }
        else
        {
            for (int i = 0; i < transfromsToMatrices.Length; i++)
            {
                Graphics.DrawMesh(meshToUse, workingMatrixes[i],
                                           material,
                                           0,
                                           null,
                                           0);
            }
        }
    }
}
