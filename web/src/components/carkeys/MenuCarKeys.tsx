import React, { useState } from "react";
import { fetchNui } from "../../utils/fetchNui";
import { useLang } from '../../utils/LangContext';
import { Button, Stack, Group, Text, Tooltip, Card, ScrollArea, ThemeIcon, Badge, CloseButton, TextInput, ActionIcon, Flex, Divider } from "@mantine/core";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { IconMapPin, IconKey, IconCarGarage, IconPencil } from '@tabler/icons-react';

import { debugData } from "../../utils/debugData";
import { isEnvBrowser } from "../../utils/misc";

debugData([
    {
        action: 'setVisibleMenu',
        data: false
    },
    {
        action: 'vehicleKeys',
        data: {
            "0858 9KE": {
                "maxGear": 0.0,
                "totalSeats": 2,
                "mileage": 0.74,
                "vehicle": "{\"tyres\":[],\"pearlescentColor\":93,\"modBackWheels\":-1,\"modHood\":-1,\"modHydrolic\":-1,\"color2\":[202,248,16],\"driftTyres\":false,\"wheelWidth\":0.0,\"modTransmission\":-1,\"modDoorSpeaker\":-1,\"bulletProofTyres\":true,\"fuelLevel\":100,\"modWindows\":-1,\"modRightFender\":-1,\"modDashboard\":-1,\"wheelColor\":156,\"modEngine\":-1,\"modTank\":-1,\"modTrimB\":-1,\"modTrunk\":-1,\"modHorns\":-1,\"modXenon\":false,\"tyreSmokeColor\":[255,255,255],\"modSuspension\":-1,\"modArchCover\":-1,\"modAirFilter\":-1,\"modSpoilers\":-1,\"modFrame\":-1,\"modSmokeEnabled\":false,\"modOrnaments\":-1,\"modTrimA\":-1,\"engineHealth\":999,\"modCustomTiresR\":false,\"modLightbar\":-1,\"modFrontWheels\":-1,\"paintType2\":0,\"windowTint\":-1,\"bodyHealth\":998,\"neonEnabled\":[false,false,false,false],\"plate\":\"0858 9KE\",\"modExhaust\":-1,\"extras\":[1],\"dashboardColor\":0,\"modLivery\":-1,\"modSteeringWheel\":-1,\"modFender\":-1,\"dirtLevel\":12,\"doors\":[],\"interiorColor\":0,\"paintType1\":0,\"modShifterLeavers\":-1,\"modSubwoofer\":-1,\"modRoofLivery\":-1,\"plateIndex\":0,\"modPlateHolder\":-1,\"modSeats\":-1,\"modSideSkirt\":-1,\"modEngineBlock\":-1,\"modStruts\":-1,\"modDoorR\":-1,\"modFrontBumper\":-1,\"modGrille\":-1,\"modHydraulics\":false,\"color1\":[207,97,51],\"modSpeakers\":-1,\"model\":1518533038,\"oilLevel\":5,\"modAerials\":-1,\"modArmor\":-1,\"modVanityPlate\":-1,\"tankHealth\":999,\"modTurbo\":false,\"modBrakes\":-1,\"modRoof\":-1,\"windows\":[2,3,4,5],\"modNitrous\":-1,\"xenonColor\":255,\"modRearBumper\":-1,\"modCustomTiresF\":false,\"modDial\":-1,\"wheelSize\":0.0,\"neonColor\":[255,0,255],\"modAPlate\":-1,\"wheels\":0}",
                "vehlabel": "mono",
                "type": "automobile",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "0858 9KE",
                "model": "HAULER",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 12,
                "engineHealth": 99.8,
                "bodyHealth": 99.9,
                "keys": "[]",
                "metadata": {
                    "fisrtOwner": "Mono Test",
                    "DoorStatus": 0,
                    "firstSpawn": "2024/10/28 16:25:43"
                },
                "carseller": 0
            },
            "I05Z Z1P": {
                "maxGear": 0.0,
                "totalSeats": 2,
                "mileage": 0.18,
                "vehicle": "{\"tyres\":[],\"pearlescentColor\":122,\"modBackWheels\":-1,\"modHood\":-1,\"modHydrolic\":-1,\"color2\":[18,18,18],\"driftTyres\":false,\"wheelWidth\":0.0,\"modTransmission\":-1,\"modDoorSpeaker\":-1,\"bulletProofTyres\":true,\"fuelLevel\":70,\"modWindows\":-1,\"modRightFender\":-1,\"modDashboard\":-1,\"wheelColor\":156,\"modEngine\":-1,\"modTank\":-1,\"modTrimB\":-1,\"modTrunk\":-1,\"modHorns\":-1,\"modXenon\":false,\"tyreSmokeColor\":[255,255,255],\"modSuspension\":-1,\"modArchCover\":-1,\"modAirFilter\":-1,\"modSpoilers\":-1,\"modFrame\":-1,\"modSmokeEnabled\":false,\"modOrnaments\":-1,\"modTrimA\":-1,\"engineHealth\":1000,\"modCustomTiresR\":false,\"modLightbar\":-1,\"modFrontWheels\":-1,\"paintType2\":0,\"windowTint\":-1,\"bodyHealth\":1000,\"neonEnabled\":[false,false,false,false],\"plate\":\"I05Z Z1P\",\"modExhaust\":-1,\"extras\":[0,1,1],\"dashboardColor\":0,\"modLivery\":3,\"modSteeringWheel\":-1,\"modFender\":-1,\"dirtLevel\":0,\"doors\":[],\"interiorColor\":0,\"paintType1\":0,\"modShifterLeavers\":-1,\"modSubwoofer\":-1,\"modRoofLivery\":-1,\"plateIndex\":0,\"modPlateHolder\":-1,\"modSeats\":-1,\"modSideSkirt\":-1,\"modEngineBlock\":-1,\"modStruts\":-1,\"modDoorR\":-1,\"modFrontBumper\":-1,\"modGrille\":-1,\"modHydraulics\":false,\"color1\":[66,66,66],\"modSpeakers\":-1,\"model\":1876516712,\"oilLevel\":6,\"modAerials\":-1,\"modArmor\":-1,\"modVanityPlate\":-1,\"tankHealth\":1000,\"modTurbo\":false,\"modBrakes\":-1,\"modRoof\":-1,\"windows\":[2,4,5,7],\"modNitrous\":-1,\"xenonColor\":255,\"modRearBumper\":-1,\"modCustomTiresF\":false,\"modDial\":-1,\"wheelSize\":0.0,\"neonColor\":[255,0,255],\"modAPlate\":-1,\"wheels\":0}",
                "vehlabel": "Brute Camper asd as das dasd as das dasd asd asd asd a da",
                "type": "automobile",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "I05Z Z1P",
                "model": "CAMPER",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 9,
                "engineHealth": 100.0,
                "bodyHealth": 100.0,
                "keys": "[]",
                "metadata": {
                    "DoorStatus": 0,
                    "firstSpawn": "2024/10/24 13:01:05"
                },
                "carseller": 0
            },
            "Z6OC VX2": {
                "maxGear": 0.0,
                "totalSeats": 2,
                "mileage": 0.82,
                "vehicle": "{\"modCustomTiresF\":false,\"bodyHealth\":873,\"pearlescentColor\":3,\"paintType1\":7,\"modDoorR\":-1,\"modSeats\":-1,\"model\":-1353081087,\"neonEnabled\":[false,false,false,false],\"modSpoilers\":-1,\"modDial\":-1,\"doors\":[],\"tyres\":[],\"modTrimB\":-1,\"modSpeakers\":-1,\"modBackWheels\":-1,\"modHydraulics\":false,\"modVanityPlate\":-1,\"modRoof\":-1,\"modArmor\":-1,\"modOrnaments\":-1,\"dirtLevel\":7,\"windowTint\":-1,\"modTransmission\":-1,\"modSuspension\":-1,\"driftTyres\":false,\"modSmokeEnabled\":false,\"modSteeringWheel\":-1,\"wheelWidth\":1.0,\"wheelSize\":1.0,\"modTrunk\":-1,\"interiorColor\":0,\"color1\":[2,245,76],\"color2\":[40,202,22],\"wheels\":6,\"windows\":[0,1,2,3,4,5,7],\"oilLevel\":5,\"modEngine\":-1,\"modSideSkirt\":-1,\"modLivery\":-1,\"modHood\":-1,\"tyreSmokeColor\":[255,255,255],\"modBrakes\":-1,\"modExhaust\":-1,\"modDashboard\":-1,\"modFender\":-1,\"plateIndex\":0,\"modNitrous\":-1,\"modFrontWheels\":-1,\"modFrame\":-1,\"modRearBumper\":-1,\"dashboardColor\":0,\"modPlateHolder\":-1,\"extras\":[],\"modCustomTiresR\":false,\"modHorns\":-1,\"neonColor\":[255,0,255],\"modXenon\":false,\"modEngineBlock\":-1,\"modShifterLeavers\":-1,\"modRightFender\":-1,\"paintType2\":7,\"xenonColor\":255,\"modAerials\":-1,\"bulletProofTyres\":true,\"modTrimA\":-1,\"modStruts\":-1,\"modFrontBumper\":-1,\"modTank\":-1,\"wheelColor\":156,\"modSubwoofer\":-1,\"plate\":\"Z6OC VX2\",\"modArchCover\":-1,\"modGrille\":-1,\"modDoorSpeaker\":-1,\"modTurbo\":false,\"modWindows\":-1,\"tankHealth\":965,\"modHydrolic\":-1,\"fuelLevel\":99,\"modAirFilter\":-1,\"engineHealth\":814,\"modRoofLivery\":-1,\"modAPlate\":-1,\"modLightbar\":-1}",
                "vehlabel": "Dinka Vindicator",
                "type": "bike",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "Z6OC VX2",
                "model": "VINDICATOR",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 5,
                "engineHealth": 87.3,
                "bodyHealth": 81.4,
                "keys": "[]",
                "metadata": {
                    "DoorStatus": 0,
                    "firstSpawn": "2024/10/19 22:24:40"
                },
                "carseller": 0
            },
            "2B8Q 5NC": {
                "maxGear": 0.0,
                "totalSeats": 4,
                "mileage": 0.09,
                "vehicle": "{\"modCustomTiresF\":false,\"bodyHealth\":1000,\"pearlescentColor\":111,\"paintType1\":7,\"modDoorR\":-1,\"modSeats\":-1,\"model\":-1883869285,\"neonEnabled\":[false,false,false,false],\"modSpoilers\":-1,\"modDial\":-1,\"doors\":[],\"tyres\":[],\"modTrimB\":-1,\"modSpeakers\":-1,\"modBackWheels\":-1,\"modHydraulics\":false,\"modVanityPlate\":-1,\"modRoof\":-1,\"modArmor\":-1,\"modOrnaments\":-1,\"dirtLevel\":10,\"windowTint\":-1,\"modTransmission\":-1,\"modSuspension\":-1,\"driftTyres\":false,\"modSmokeEnabled\":false,\"modSteeringWheel\":-1,\"wheelWidth\":1.0,\"wheelSize\":1.0,\"modTrunk\":-1,\"interiorColor\":0,\"color1\":[76,52,153],\"color2\":[169,97,91],\"wheels\":0,\"windows\":[4,5],\"oilLevel\":5,\"modEngine\":-1,\"modSideSkirt\":-1,\"modLivery\":-1,\"modHood\":-1,\"tyreSmokeColor\":[255,255,255],\"modBrakes\":-1,\"modExhaust\":-1,\"modDashboard\":-1,\"modFender\":-1,\"plateIndex\":3,\"modNitrous\":-1,\"modFrontWheels\":-1,\"modFrame\":-1,\"modRearBumper\":-1,\"dashboardColor\":0,\"modPlateHolder\":-1,\"extras\":{\"11\":1,\"12\":0},\"modCustomTiresR\":false,\"modHorns\":-1,\"neonColor\":[255,0,255],\"modXenon\":false,\"modEngineBlock\":-1,\"modShifterLeavers\":-1,\"modRightFender\":-1,\"paintType2\":7,\"xenonColor\":255,\"modAerials\":-1,\"bulletProofTyres\":true,\"modTrimA\":-1,\"modStruts\":-1,\"modFrontBumper\":-1,\"modTank\":-1,\"wheelColor\":156,\"modSubwoofer\":-1,\"plate\":\"2B8Q 5NC\",\"modArchCover\":-1,\"modGrille\":-1,\"modDoorSpeaker\":-1,\"modTurbo\":false,\"modWindows\":-1,\"tankHealth\":1000,\"modHydrolic\":-1,\"fuelLevel\":100,\"modAirFilter\":-1,\"engineHealth\":1000,\"modRoofLivery\":-1,\"modAPlate\":-1,\"modLightbar\":-1}",
                "vehlabel": "Declasse Premier",
                "type": "automobile",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "2B8Q 5NC",
                "model": "PREMIER",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 7,
                "engineHealth": 100.0,
                "bodyHealth": 100.0,
                "keys": "[]",
                "metadata": {
                    "DoorStatus": 0,
                    "firstSpawn": "2024/10/24 12:46:02"
                },
                "carseller": 0
            },
            "BF5Z W3W": {
                "maxGear": 0.0,
                "totalSeats": 4,
                "mileage": 3.43,
                "vehicle": "{\"bodyHealth\":979,\"paintType1\":7,\"modExhaust\":-1,\"modDoorSpeaker\":-1,\"modCustomTiresF\":false,\"xenonColor\":255,\"modBrakes\":-1,\"modTrunk\":-1,\"modVanityPlate\":-1,\"modRoofLivery\":-1,\"modOrnaments\":-1,\"oilLevel\":5,\"modTrimB\":-1,\"modDoorR\":-1,\"wheels\":0,\"modArmor\":-1,\"modFrontWheels\":-1,\"modStruts\":-1,\"modFrame\":-1,\"modLightbar\":-1,\"modBackWheels\":-1,\"modSuspension\":-1,\"modCustomTiresR\":false,\"modAerials\":-1,\"fuelLevel\":65,\"modDial\":-1,\"modSpoilers\":-1,\"modSteeringWheel\":-1,\"windows\":[0],\"modTrimA\":-1,\"tyreSmokeColor\":[255,255,255],\"modSmokeEnabled\":false,\"wheelSize\":1.0,\"neonColor\":[255,0,255],\"color2\":[3,140,156],\"model\":-1372848492,\"modNitrous\":-1,\"modFender\":-1,\"modWindows\":-1,\"modGrille\":-1,\"doors\":[],\"modHorns\":-1,\"engineHealth\":973,\"modTurbo\":false,\"color1\":[208,104,55],\"interiorColor\":0,\"modSpeakers\":-1,\"modShifterLeavers\":-1,\"driftTyres\":false,\"bulletProofTyres\":true,\"neonEnabled\":[false,false,false,false],\"plate\":\"BF5Z W3W\",\"pearlescentColor\":7,\"extras\":[],\"modAPlate\":-1,\"modHydraulics\":false,\"modSubwoofer\":-1,\"modRoof\":-1,\"windowTint\":-1,\"tankHealth\":997,\"modEngine\":-1,\"paintType2\":7,\"modTransmission\":-1,\"wheelWidth\":1.0,\"modRearBumper\":-1,\"modRightFender\":-1,\"dirtLevel\":0,\"modLivery\":-1,\"modXenon\":false,\"modEngineBlock\":-1,\"modTank\":-1,\"modArchCover\":-1,\"modSeats\":-1,\"modAirFilter\":-1,\"modSideSkirt\":-1,\"modPlateHolder\":-1,\"modFrontBumper\":-1,\"wheelColor\":156,\"plateIndex\":0,\"tyres\":[],\"dashboardColor\":0,\"modHydrolic\":-1,\"modDashboard\":-1,\"modHood\":-1}",
                "vehlabel": "Karin Kuruma",
                "type": "automobile",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "BF5Z W3W",
                "model": "KURUMA",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 6,
                "engineHealth": 97.9,
                "bodyHealth": 97.3,
                "keys": "[]",
                "metadata": {
                    "radio": true,
                    "vehname": "Karin Kuruma",
                    "DoorStatus": 2,
                    "firstSpawn": "2024/10/19 22:28:37"
                },
                "carseller": 0
            },
            "5368 7TI": {
                "maxGear": 0.0,
                "totalSeats": 2,
                "mileage": 0.0,
                "vehicle": "{\"modTransmission\":-1,\"model\":-1523428744,\"modSideSkirt\":-1,\"wheelWidth\":1.0,\"modDashboard\":-1,\"wheelSize\":1.0,\"paintType1\":7,\"modOrnaments\":-1,\"wheels\":6,\"modSpoilers\":-1,\"plate\":\"5368 7TI\",\"modRightFender\":-1,\"tyres\":[],\"doors\":[],\"modRearBumper\":-1,\"modSteeringWheel\":-1,\"modAirFilter\":-1,\"modFrontBumper\":-1,\"color2\":[60,38,230],\"dashboardColor\":0,\"tyreSmokeColor\":[255,255,255],\"modSpeakers\":-1,\"tankHealth\":1000,\"modTank\":-1,\"modHorns\":-1,\"engineHealth\":1000,\"modFender\":-1,\"modTrimB\":-1,\"modWindows\":-1,\"modTrunk\":-1,\"modAPlate\":-1,\"modDoorR\":-1,\"neonColor\":[255,0,255],\"modFrame\":-1,\"modHood\":-1,\"modXenon\":false,\"modLivery\":-1,\"modSuspension\":-1,\"color1\":[253,49,231],\"modCustomTiresF\":false,\"modShifterLeavers\":-1,\"bulletProofTyres\":true,\"windows\":[0,1,2,3,4,5,6,7],\"pearlescentColor\":53,\"plateIndex\":0,\"modNitrous\":-1,\"extras\":[],\"modRoofLivery\":-1,\"modFrontWheels\":-1,\"modBrakes\":-1,\"wheelColor\":156,\"dirtLevel\":10,\"modVanityPlate\":-1,\"fuelLevel\":100,\"modSubwoofer\":-1,\"modEngine\":-1,\"modSeats\":-1,\"modHydraulics\":false,\"modLightbar\":-1,\"interiorColor\":0,\"modTrimA\":-1,\"modDial\":-1,\"modDoorSpeaker\":-1,\"driftTyres\":false,\"modSmokeEnabled\":false,\"modArmor\":-1,\"modHydrolic\":-1,\"windowTint\":-1,\"modArchCover\":-1,\"modGrille\":-1,\"modExhaust\":-1,\"modPlateHolder\":-1,\"paintType2\":7,\"modRoof\":-1,\"bodyHealth\":1000,\"modCustomTiresR\":false,\"modTurbo\":false,\"oilLevel\":5,\"neonEnabled\":[false,false,false,false],\"modStruts\":-1,\"modBackWheels\":-1,\"modAerials\":-1,\"modEngineBlock\":-1,\"xenonColor\":255}",
                "vehlabel": "Maibatsu Manchez",
                "type": "bike",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "5368 7TI",
                "model": "MANCHEZ",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 11,
                "engineHealth": 100.0,
                "bodyHealth": 100.0,
                "keys": "[]",
                "metadata": {
                    "DoorStatus": 0,
                    "fisrtOwner": "Mono Test",
                    "firstSpawn": "2024/10/28 01:24:42"
                },
                "carseller": 0
            },
            "ZNV6 YC4": {
                "maxGear": 0.0,
                "totalSeats": 0,
                "mileage": 0.0,
                "vehicle": "{\"modCustomTiresF\":false,\"bodyHealth\":974,\"pearlescentColor\":4,\"paintType1\":0,\"modDoorR\":-1,\"modSeats\":-1,\"model\":2078290630,\"neonEnabled\":[false,false,false,false],\"modSpoilers\":-1,\"modDial\":-1,\"doors\":[],\"tyres\":[],\"modTrimB\":-1,\"modSpeakers\":-1,\"modBackWheels\":-1,\"modHydraulics\":false,\"modVanityPlate\":-1,\"modRoof\":-1,\"modArmor\":-1,\"modOrnaments\":-1,\"dirtLevel\":6,\"windowTint\":-1,\"modTransmission\":-1,\"modSuspension\":-1,\"driftTyres\":false,\"modSmokeEnabled\":false,\"modSteeringWheel\":-1,\"wheelWidth\":0.0,\"wheelSize\":0.0,\"modTrunk\":-1,\"interiorColor\":0,\"color1\":[64,42,71],\"color2\":[35,132,130],\"wheels\":0,\"windows\":[0,1,2,3,4,5,6,7],\"oilLevel\":0,\"modEngine\":-1,\"modSideSkirt\":-1,\"modLivery\":-1,\"modHood\":-1,\"tyreSmokeColor\":[255,255,255],\"modBrakes\":-1,\"modExhaust\":-1,\"modDashboard\":-1,\"modFender\":-1,\"plateIndex\":0,\"modNitrous\":-1,\"modFrontWheels\":-1,\"modFrame\":-1,\"modRearBumper\":-1,\"dashboardColor\":0,\"modPlateHolder\":-1,\"extras\":[],\"modCustomTiresR\":false,\"modHorns\":-1,\"neonColor\":[255,0,255],\"modXenon\":false,\"modEngineBlock\":-1,\"modShifterLeavers\":-1,\"modRightFender\":-1,\"paintType2\":0,\"xenonColor\":255,\"modAerials\":-1,\"bulletProofTyres\":true,\"modTrimA\":-1,\"modStruts\":-1,\"modFrontBumper\":-1,\"modTank\":-1,\"wheelColor\":156,\"modSubwoofer\":-1,\"plate\":\"ZNV6 YC4\",\"modArchCover\":-1,\"modGrille\":-1,\"modDoorSpeaker\":-1,\"modTurbo\":false,\"modWindows\":-1,\"tankHealth\":1000,\"modHydrolic\":-1,\"fuelLevel\":100,\"modAirFilter\":-1,\"engineHealth\":1000,\"modRoofLivery\":-1,\"modAPlate\":-1,\"modLightbar\":-1}",
                "vehlabel": " Trailer",
                "type": "trailer",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "ZNV6 YC4",
                "model": "TRAILER",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 10,
                "engineHealth": 97.4,
                "bodyHealth": 100.0,
                "keys": "[]",
                "metadata": {
                    "fisrtOwner": "Mono Test",
                    "DoorStatus": 1,
                    "firstSpawn": "2024/10/28 00:18:49"
                },
                "carseller": 0
            },
            "S7F4 LBN": {
                "maxGear": 0.0,
                "totalSeats": 4,
                "mileage": 0.03,
                "vehicle": "{\"dirtLevel\":8,\"modLightbar\":-1,\"fuelLevel\":100,\"modFrontBumper\":-1,\"modFender\":-1,\"modTransmission\":-1,\"modSeats\":-1,\"engineHealth\":1000,\"modWindows\":-1,\"plate\":\"S7F4 LBN\",\"modBackWheels\":-1,\"neonColor\":[255,0,255],\"modDoorR\":-1,\"neonEnabled\":[false,false,false,false],\"modNitrous\":-1,\"modAPlate\":-1,\"modGrille\":-1,\"modHydraulics\":false,\"modDoorSpeaker\":-1,\"modSubwoofer\":-1,\"modArchCover\":-1,\"modTank\":-1,\"xenonColor\":255,\"modSideSkirt\":-1,\"modTrimB\":-1,\"modRightFender\":-1,\"modDashboard\":-1,\"driftTyres\":false,\"plateIndex\":0,\"modSmokeEnabled\":false,\"modLivery\":-1,\"modArmor\":-1,\"modExhaust\":-1,\"modFrame\":-1,\"modHorns\":-1,\"modRearBumper\":-1,\"pearlescentColor\":112,\"modTrimA\":-1,\"tyreSmokeColor\":[255,255,255],\"modFrontWheels\":-1,\"modTrunk\":-1,\"modRoofLivery\":-1,\"bulletProofTyres\":true,\"modEngineBlock\":-1,\"tankHealth\":1000,\"modAirFilter\":-1,\"tyres\":[],\"modPlateHolder\":-1,\"modVanityPlate\":-1,\"wheelWidth\":0.0,\"modRoof\":-1,\"modCustomTiresR\":false,\"modXenon\":false,\"doors\":[],\"wheelColor\":6,\"color1\":[44,250,148],\"model\":167522317,\"bodyHealth\":1000,\"modEngine\":-1,\"modCustomTiresF\":false,\"modTurbo\":false,\"modHydrolic\":-1,\"windows\":[4,5],\"modSpoilers\":-1,\"windowTint\":-1,\"modHood\":-1,\"modOrnaments\":-1,\"paintType1\":7,\"dashboardColor\":156,\"wheels\":3,\"modAerials\":-1,\"extras\":[0],\"interiorColor\":8,\"oilLevel\":5,\"modDial\":-1,\"modSteeringWheel\":-1,\"modStruts\":-1,\"paintType2\":7,\"modBrakes\":-1,\"modShifterLeavers\":-1,\"color2\":[180,69,169],\"modSuspension\":-1,\"wheelSize\":0.0,\"modSpeakers\":-1}",
                "carseller": 0,
                "type": "automobile",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "S7F4 LBN",
                "coords": "{\"x\":230.79833984375,\"y\":-776.1099243164063,\"z\":30.47997093200683,\"w\":70.18766784667969}",
                "parking": "Pillbox Hill",
                "stored": 0,
                "id": 13,
                "engineHealth": 100.0,
                "bodyHealth": 100.0,
                "metadata": {
                    "DoorStatus": 2,
                    "fisrtOwner": "Mono Test",
                    "firstSpawn": "2024/11/08 17:15:47"
                },
                "keys": "[]",
                "vehlabel": "Canis Terminus",
                "model": "TERMINUS"
            },
            "ON53 6TG": {
                "maxGear": 0.0,
                "totalSeats": 4,
                "mileage": 2.48,
                "vehicle": "{\"modCustomTiresF\":false,\"bodyHealth\":894,\"pearlescentColor\":27,\"paintType1\":7,\"modDoorR\":-1,\"modSeats\":-1,\"model\":-1756021720,\"neonEnabled\":[false,false,false,false],\"modSpoilers\":-1,\"modDial\":-1,\"doors\":[],\"tyres\":[],\"modTrimB\":-1,\"modSpeakers\":-1,\"modBackWheels\":-1,\"modHydraulics\":false,\"modVanityPlate\":-1,\"modRoof\":-1,\"modArmor\":-1,\"modOrnaments\":-1,\"dirtLevel\":14,\"windowTint\":-1,\"modTransmission\":-1,\"modSuspension\":-1,\"driftTyres\":false,\"modSmokeEnabled\":false,\"modSteeringWheel\":-1,\"wheelWidth\":1.0,\"wheelSize\":1.0,\"modTrunk\":-1,\"interiorColor\":8,\"color1\":[13,49,195],\"color2\":[74,199,46],\"wheels\":3,\"windows\":[4,5,6],\"oilLevel\":5,\"modEngine\":-1,\"modSideSkirt\":-1,\"modLivery\":-1,\"modHood\":-1,\"tyreSmokeColor\":[255,255,255],\"modBrakes\":-1,\"modExhaust\":-1,\"modDashboard\":-1,\"modFender\":-1,\"plateIndex\":0,\"modNitrous\":-1,\"modFrontWheels\":-1,\"modFrame\":-1,\"modRearBumper\":-1,\"dashboardColor\":156,\"modPlateHolder\":-1,\"extras\":[],\"modCustomTiresR\":false,\"modHorns\":-1,\"neonColor\":[255,0,255],\"modXenon\":false,\"modEngineBlock\":-1,\"modShifterLeavers\":-1,\"modRightFender\":-1,\"paintType2\":7,\"xenonColor\":255,\"modAerials\":-1,\"bulletProofTyres\":true,\"modTrimA\":-1,\"modStruts\":-1,\"modFrontBumper\":-1,\"modTank\":-1,\"wheelColor\":0,\"modSubwoofer\":-1,\"plate\":\"ON53 6TG\",\"modArchCover\":-1,\"modGrille\":-1,\"modDoorSpeaker\":-1,\"modTurbo\":false,\"modWindows\":-1,\"tankHealth\":983,\"modHydrolic\":-1,\"fuelLevel\":100,\"modAirFilter\":-1,\"engineHealth\":989,\"modRoofLivery\":-1,\"modAPlate\":-1,\"modLightbar\":-1}",
                "vehlabel": "Karin Everon",
                "type": "automobile",
                "lastparking": "Pillbox Hill",
                "private": false,
                "owner": "char1:559586a641fc2fbf1077189e89cd24ad50b43f01",
                "plate": "ON53 6TG",
                "model": "EVERON",
                "parking": "Pillbox Hill",
                "stored": 1,
                "id": 8,
                "engineHealth": 89.4,
                "bodyHealth": 98.9,
                "keys": "[]",
                "metadata": {
                    "vehname": "Custom Name @",
                    "DoorStatus": 0,
                    "firstSpawn": "2024/10/24 12:48:19"
                },
                "carseller": 0
            }
        }
    }
], 100);

const Menu: React.FC<{ visible: boolean }> = ({ visible }) => {
    const [vehicleKeys, setVehicleKeys] = useState<any>({});
    const [selectedVehicle, setSelectedVehicle] = useState<any>(null);
    const lang = useLang();
    const [searchQuery, setSearchQuery] = useState<string>('');


    const handleClose = () => {
        fetchNui('ui:Close', { name: 'setVisibleMenu' });
    };

    const handleGpsClick = (coords: string) => {
        const parsedCoords = JSON.parse(coords);
        fetchNui('setGPS', { coords: parsedCoords });
    };

    const handleKeysClick = (vehicle: any) => {
        setSelectedVehicle(vehicle);
        fetchNui('show:VehicleKeys', vehicle);
    };

    useNuiEvent<any>('vehicleKeys', (data) => {
        setVehicleKeys(data);
    });

    const filteredVehicles = Object.entries(vehicleKeys).filter(([plate, info]: [string, any]) => {
        const searchLower = searchQuery.toLowerCase();
        return (
            plate.toLowerCase().includes(searchLower) ||
            (info.vehlabel || '').toLowerCase().includes(searchLower) ||
            (info.parking || '').toLowerCase().includes(searchLower)
        );
    });

    return (

        <div className={visible ? "menu visible" : "menu no-visible"} >

            <Flex justify="space-between" align="center" w="100%">
                <Text size={17} weight={500} style={{ flexGrow: 1, textAlign: "center" }}>
                    {lang.carkey_menu1}
                </Text>
                <CloseButton size={"md"} onClick={handleClose} />
            </Flex>
            <Divider />
            <TextInput
                placeholder="Search: Plate, model, name..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.currentTarget.value)}
                size="xs"
                variant="filled"


            />
            <Divider />
            <ScrollArea h={300} scrollbarSize={4}>
                <Stack spacing={10}>
                    {filteredVehicles
                        .sort((a, b) => {
                            const hasCoordsA = (a[1] as any).coords ? 1 : 0;
                            const hasCoordsB = (b[1] as any).coords ? 1 : 0;

                            if (hasCoordsA !== hasCoordsB) {
                                return hasCoordsB - hasCoordsA;
                            }

                            const storedA = (a[1] as any).stored;
                            const storedB = (b[1] as any).stored;
                            return storedA - storedB;
                        })
                        .map(([plate, info]: [string, any]) => (

                            <Card key={plate} p={10} bg={'#2C2E33'} withBorder sx={{
                                '&:hover': {
                                    boxShadow: 'inset 0px 0px 60px 1px rgba(255, 255, 255, 0.06)',
                                },
                            }}>

                                <Stack spacing={10}>

                                    <Group position="apart">

                                        <Flex align="center" gap={10}>
                                            <Tooltip label={`${lang.givecar_menu2}: ${info.parking ?? '?'}`} color={info.stored === 1 ? 'teal' : 'red'} position="top" withArrow withinPortal>
                                                <ThemeIcon variant="light" size={'lg'} color={info.stored === 1 ? 'teal' : 'red'} >
                                                    <IconCarGarage size={24} />
                                                </ThemeIcon>
                                            </Tooltip>
                                            <Badge color="dark" radius={4} >{plate}</Badge>
                                        </Flex>
                                        <Group position="right" sx={{ gap: 10 }}>
                                            {info.coords && (
                                                <Tooltip label={lang.carkey_menu8} position="top" withArrow withinPortal>
                                                    <ActionIcon radius="md" size="sm" variant="light" color="green" onClick={() => handleGpsClick(info.coords)} ><IconMapPin size={15} /></ActionIcon>
                                                </Tooltip>
                                            )}

                                            <Tooltip label={lang.carkey_menu3} position="top" withArrow withinPortal>
                                                <ActionIcon radius="md" size="sm" variant="light" color="yellow" onClick={() => handleKeysClick(info)} ><IconKey size={15} /></ActionIcon>
                                            </Tooltip>

                                        </Group>
                                    </Group>



                                    <Text fw={500} size={14} >
                                        {info.vehlabel.length > 30 ? `${info.vehlabel.substring(0, 30)}...` : info.vehlabel}
                                    </Text>

                                </Stack>

                            </Card>
                        ))}
                </Stack>
            </ScrollArea>
        </ div>

    );
};

export default Menu;
