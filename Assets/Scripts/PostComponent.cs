using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostComponent : MonoBehaviour
{
    [SerializeField] Material postProcessMaterial;
    [SerializeField] float scanSpeed;
    [SerializeField] bool scanActivated;


    float scanDist;
    Camera cam;

    private void Start()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    //private void Update()
    //{
    //    if (scanActivated)
    //        scanDist += Time.deltaTime * scanSpeed;
    //    else
    //        scanDist = 0;

    //    if (scanDist >= Camera.main.farClipPlane)
    //        scanDist = 0;

    //}

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //postProcessMaterial.SetFloat("_ScanDistance", scanDist);

        //Matrix4x4 viewToWorld = cam.cameraToWorldMatrix;
        //postProcessMaterial.SetMatrix("_ViewToWorldMTX", viewToWorld);

        Graphics.Blit(source, destination, postProcessMaterial);
    }
}
