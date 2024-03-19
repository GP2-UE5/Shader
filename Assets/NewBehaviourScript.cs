using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    private int shaderPlayerPos = Shader.PropertyToID("_PlayerPos");

    Mesh m;

    void Start()
    {
        //m = GetComponent<MeshFilter>().mesh;
    }


    void Update()
    {
        //Vector3[] vertPos = new Vector3[m.vertexCount];

        //for (int i = 0; i < m.vertexCount; i++)
        //{
        //    vertPos[i] = m.vertices[i] + Vector3.up * Mathf.Sin(Time.time) * 0.1f;
        //}

        //m.SetVertices(vertPos);


        Shader.SetGlobalVector(shaderPlayerPos, transform.position);
    }
}
