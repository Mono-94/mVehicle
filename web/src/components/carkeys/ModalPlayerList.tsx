import React, { useState, useEffect } from 'react';
import { Modal, TextInput, Button, Stack, Text, Group, ActionIcon, ScrollArea, Card, Center } from '@mantine/core';
import { fetchNui } from '../../utils/fetchNui';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { debugData } from '../../utils/debugData';
import { isEnvBrowser } from '../../utils/misc';
import { IconPlus, IconSearch, IconTrash, IconUser, IconX } from '@tabler/icons-react';

interface KeyManagerProps {
    visible: boolean;
    vehicle?: any;
}

debugData([
    {
        action: 'setVisibleModal',
        data: false,
    },
    {
        action: 'manageKey',
        data: {
            "metadata": "{\"firstSpawn\":\"2024/07/30 10:06:50\",\"DoorStatus\":0,\"vehname\":\"El PRogren\"}",
            "parking": "adssad",
            "vehlabel": "El PRogren",
            "type": "automobile",
            "carseller": 0,
            "mileage": 0,
            "vehicle": "{\"modSmokeEnabled\":false,\"doors\":[],\"tankHealth\":1000,\"color2\":[143,191,226],\"modCustomTiresF\":false,\"bodyHealth\":1000,\"color1\":[230,143,5],\"modTrunk\":-1,\"modTrimA\":-1,\"modWindows\":-1,\"modSuspension\":-1,\"modSteeringWheel\":-1,\"modXenon\":false,\"modNitrous\":-1,\"oilLevel\":5,\"modLivery\":-1,\"wheelSize\":1.0,\"modSpoilers\":-1,\"modHydrolic\":-1,\"pearlescentColor\":3,\"modFender\":-1,\"modTurbo\":false,\"model\":1663218586,\"modTransmission\":-1,\"engineHealth\":1000,\"driftTyres\":false,\"modDoorSpeaker\":-1,\"modStruts\":-1,\"modSubwoofer\":-1,\"plateIndex\":0,\"modBackWheels\":-1,\"modRoofLivery\":-1,\"modAirFilter\":-1,\"paintType2\":7,\"dirtLevel\":1,\"modLightbar\":-1,\"modOrnaments\":-1,\"modAerials\":-1,\"modAPlate\":-1,\"modVanityPlate\":-1,\"modDoorR\":-1,\"modExhaust\":-1,\"modShifterLeavers\":-1,\"modHood\":-1,\"extras\":[],\"xenonColor\":255,\"modRightFender\":-1,\"modEngineBlock\":-1,\"windows\":[2,3,4,5],\"dashboardColor\":0,\"tyres\":[],\"bulletProofTyres\":true,\"modTank\":-1,\"windowTint\":-1,\"modTrimB\":-1,\"modRoof\":-1,\"modCustomTiresR\":false,\"modRearBumper\":-1,\"modHydraulics\":false,\"neonColor\":[255,0,255],\"modFrontBumper\":-1,\"fuelLevel\":100,\"modSeats\":-1,\"tyreSmokeColor\":[255,255,255],\"modEngine\":-1,\"modHorns\":-1,\"wheelWidth\":1.0,\"paintType1\":7,\"modSpeakers\":-1,\"modArchCover\":-1,\"modPlateHolder\":-1,\"modDashboard\":-1,\"wheelColor\":0,\"plate\":\"9R8A 2F3\",\"modGrille\":-1,\"modDial\":-1,\"modArmor\":-1,\"interiorColor\":0,\"modFrame\":-1,\"modFrontWheels\":-1,\"wheels\":7,\"modBrakes\":-1,\"modSideSkirt\":-1,\"neonEnabled\":[false,false,false,false]}",
            "plate": "9R8A 2F3",
            "keys": "{\"char1/559586a641fc2fbf1077189e89cd24ad50b43f01\":\"Alice Johnson\",\"char2/559586a641fc2fbf1077189e89cd24ad50b43f02\":\"Bob Smith\",\"char3/559586a641fc2fbf1077189e89cd24ad50b43f03\":\"Charlie Brown\",\"char4/559586a641fc2fbf1077189e89cd24ad50b43f04\":\"Diana Prince\",\"char5/559586a641fc2fbf1077189e89cd24ad50b43f05\":\"Ethan Hunt\",\"char6/559586a641fc2fbf1077189e89cd24ad50b43f06\":\"Fiona Clark\",\"char7/559586a641fc2fbf1077189e89cd24ad50b43f07\":\"George White\",\"char8/559586a641fc2fbf1077189e89cd24ad50b43f08\":\"Hannah Lee\",\"char9/559586a641fc2fbf1077189e89cd24ad50b43f09\":\"Ian Scott\",\"char10/559586a641fc2fbf1077189e89cd24ad50b43f10\":\"Jane Doe\",\"char11/559586a641fc2fbf1077189e89cd24ad50b43f11\":\"Kyle Brown\",\"char12/559586a641fc2fbf1077189e89cd24ad50b43f12\":\"Lily Evans\",\"char13/559586a641fc2fbf1077189e89cd24ad50b43f13\":\"Michael Gray\",\"char14/559586a641fc2fbf1077189e89cd24ad50b43f14\":\"Nancy Drew\",\"char15/559586a641fc2fbf1077189e89cd24ad50b43f15\":\"Oliver Twist\",\"char16/559586a641fc2fbf1077189e89cd24ad50b43f16\":\"Paula Green\",\"char17/559586a641fc2fbf1077189e89cd24ad50b43f17\":\"Quinn Harper\",\"char18/559586a641fc2fbf1077189e89cd24ad50b43f18\":\"Rachel Moore\",\"char19/559586a641fc2fbf1077189e89cd24ad50b43f19\":\"Sam Turner\",\"char20/559586a641fc2fbf1077189e89cd24ad50b43f20\":\"Tina Fey\",\"char21/559586a641fc2fbf1077189e89cd24ad50b43f21\":\"Uma Thurman\",\"char22/559586a641fc2fbf1077189e89cd24ad50b43f22\":\"Victor Hugo\",\"char23/559586a641fc2fbf1077189e89cd24ad50b43f23\":\"Walter White\",\"char24/559586a641fc2fbf1077189e89cd24ad50b43f24\":\"Xander Cage\",\"char25/559586a641fc2fbf1077189e89cd24ad50b43f25\":\"Yvonne Strahovski\",\"char26/559586a641fc2fbf1077189e89cd24ad50b43f26\":\"Zara Banks\",\"char27/559586a641fc2fbf1077189e89cd24ad50b43f27\":\"Amy Adams\",\"char28/559586a641fc2fbf1077189e89cd24ad50b43f28\":\"Brian Griffin\",\"char29/559586a641fc2fbf1077189e89cd24ad50b43f29\":\"Carla Cruz\",\"char30/559586a641fc2fbf1077189e89cd24ad50b43f30\":\"David Smith\"}",
            "stored": 1,
            "owner": "char1/559586a641fc2fbf1077189e89cd24ad50b43f01",
            "private": false,
            "id": 1,
            "lastparking": "adssad"
        }
    }

], 100);

const KeyManager: React.FC<KeyManagerProps> = ({ visible, vehicle }) => {
    const [newKey, setNewKey] = useState('');
    const [vehicleData, setVehicleData] = useState<any>(vehicle);
    const [searchText, setSearchText] = useState('');

    useNuiEvent<any>('manageKey', (data) => {
        setVehicleData(data);
    });

    const handleAddKey = async () => {
        const ret = await fetchNui('mVehicle:VehicleMenu_ui', { action: 'addkey', data: vehicleData, key: newKey });
        if (ret) { handleClose(); }
    };

    const handleRemoveKey = async (key: string) => {
        const ret = await fetchNui('mVehicle:VehicleMenu_ui', { action: 'removekey', data: vehicleData, key: key });
        if (ret) {
            handleClose();
        }
    };

    const handleClose = () => {
        fetchNui('ui:Close', { name: 'setVisibleModal' });
        setSearchText('');
        setNewKey('');
    };

    const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setSearchText(event.currentTarget.value);
    };

    const handleClearSearch = () => {
        setSearchText('');
    };

    const filteredKeys = vehicleData && vehicleData.keys ? Object.entries(JSON.parse(vehicleData.keys)).filter(([key, name]) =>
        (name as string).toLowerCase().includes(searchText.toLowerCase())
    ) : [];

    return (
        <Modal opened={visible} onClose={handleClose} title="Manage Keys" centered h={300} withOverlay={false}>
            <Card withBorder p={5}>

                <Group position="apart" grow>
                    <TextInput
                        value={newKey}
                        label="Add new friend"
                        onChange={(event) => setNewKey(event.currentTarget.value)}
                        placeholder="Player ID"
                        size='xs'
                        rightSection={<ActionIcon color='green' size='xs' variant='light' onClick={handleAddKey}>
                            <IconPlus size={20} />
                        </ActionIcon>}
                    />
                    <TextInput
                        value={searchText}
                        label="Search friend"
                        onChange={handleSearchChange}
                        placeholder="Search"
                        size='xs'
                        rightSection={
                            <ActionIcon color={searchText ? 'red' : 'yellow'} size='xs' variant='light' onClick={searchText ? handleClearSearch : undefined}>
                                {searchText ? <IconX size={20} /> : <IconSearch size={20} />}
                            </ActionIcon>
                        }
                    />
                </Group>
            </Card>

            <Stack mt={20} h={300}>

                {filteredKeys.length > 0 ? (
                    <ScrollArea h={300} scrollbarSize={0}>
                        <Stack spacing={5}>
                            {filteredKeys.map(([key, name]) => (
                                <Card key={key} withBorder p={5}>
                                    <Group position="apart">
                                        <Group spacing={4}>
                                            <IconUser size={20} />
                                            <Text>{name as string}</Text>
                                        </Group>
                                        <ActionIcon color='red' variant='light' onClick={() => handleRemoveKey(key)}>
                                            <IconTrash size={20} />
                                        </ActionIcon>
                                    </Group>
                                </Card>
                            ))}
                        </Stack>
                    </ScrollArea>
                ) : (

                    <Text align='center'>No keys found</Text>

                )}

            </Stack>
        </Modal>
    );
};

export default KeyManager;