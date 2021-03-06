﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActivateNumber : MonoBehaviour
{
    [SerializeField] private List<HordeController> allHordes = new List<HordeController>();
    [SerializeField] private UnityEngine.UI.Slider slider = null;
    [SerializeField] private UnityEngine.UI.Text numberDisplay = null;
    [SerializeField] private int startFrom = 50;
    private int allNumber = 0;

    private void Awake()
    {
        slider.onValueChanged.AddListener(ChangeNumber);
        // ChangeNumber(300);
        slider.value = startFrom;
        var isSupported = SystemInfo.supportsInstancing;
    }

    private void ChangeNumber(float value)
    {
        int number = Mathf.FloorToInt(value);
        allNumber = 0;
        foreach (var item in allHordes)
        {
            item.ChangeNumberTo(0);
        }

        foreach (var item in allHordes)
        {
            if (number > 0)
            {
                int howMuchToActivate = number - item.Count > 0 ? item.Count : number;
                item.ChangeNumberTo(howMuchToActivate);
                number -= howMuchToActivate;
                allNumber += howMuchToActivate;
            }
            else
            {
                break;
            }
        }

        numberDisplay.text = allNumber.ToString();
    }
}
