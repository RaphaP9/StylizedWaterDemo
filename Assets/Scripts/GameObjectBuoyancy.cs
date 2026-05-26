using UnityEngine;

public class GameObjectBuoyancy : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private bool enableOscilation;
    [SerializeField, Range(0f, 1f)] private float amplitude = 0.25f;
    [SerializeField, Range(0.1f, 5f)] private float frequency = 1f;

    private Vector3 startPosition;

    private void Awake()
    {
        SaveStartYPosition();
    }

    private void SaveStartYPosition()
    {
        startPosition = transform.localPosition;
    }

    private void Update()
    {
        HanleOscilation();
    }

    private void HanleOscilation()
    {
        if (!enableOscilation) return;

        float yOffset = Mathf.Sin(Time.time * frequency * Mathf.PI * 2f) * amplitude;
        transform.localPosition = startPosition + new Vector3(0f, yOffset, 0f);
    }
}
