import React, { useEffect, useState, useRef, useCallback } from 'react';
import { Card, TextInput, Stack, Group, Slider, ActionIcon, Transition, Button, ScrollArea, SimpleGrid, Text } from '@mantine/core';
import { IconDeviceFloppy, IconList, IconListCheck, IconPlayerPause, IconPlayerPlay, IconSearch, IconStar, IconTrash, IconX } from '@tabler/icons-react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import { isEnvBrowser } from '../../utils/misc';
import { debugData } from '../../utils/debugData';

debugData([
    {
        action: 'radioData',
        data: {
            timeStamp: 6,
            id: 'ADMINCAR',
            soundExists: false,
            playing: false,
            paused: false,
            maxDuration: 225,
            playlist: {
                [1]: {
                    name: 'Song 1',
                    link: 'https://youtu.be/3K4MMGmh6ks?list=RDGMEMHDXYb1_DDSgDsobPsOFxpAVM3K4MMGmh6ks',

                },
                [2]: {
                    name: 'Song 2',
                    link: 'https://youtu.be/3K4MMGmh6ks?list=RDGMEMHDXYb1_DDSgDsobPsOFxpAVM3K4MMGmh6ks',

                },
                [3]: {
                    name: 'Song 3',
                    link: 'https://youtu.be/3K4MMGmh6ks?list=RDGMEMHDXYb1_DDSgDsobPsOFxpAVM3K4MMGmh6ks',

                },

            }
        },

    },
    {
        action: 'playList',
        data: {
            playlist: {
                [1]: {
                    name: 'Song 1',
                    link: 'https://youtu.be/3K4MMGmh6ks?list=RDGMEMHDXYb1_DDSgDsobPsOFxpAVM3K4MMGmh6ks',

                },
                [2]: {
                    name: 'Song 2',
                    link: 'https://youtu.be/3K4MMGmh6ks?list=RDGMEMHDXYb1_DDSgDsobPsOFxpAVM3K4MMGmh6ks',

                },
                [3]: {
                    name: 'Song 3',
                    link: 'https://youtu.be/3K4MMGmh6ks?list=RDGMEMHDXYb1_DDSgDsobPsOFxpAVM3K4MMGmh6ks',

                },

            }
        },

    },
], 100);



const RadioComponent: React.FC<{ visible: boolean }> = ({ visible }) => {
    const [songLink, setSongLink] = useState('');
    const [radioData, setRadioData] = useState<any>({});
    const [volume, setVolume] = useState(35);
    const [searchTerm, setSearchTerm] = useState('');
    const { soundExists, playing, paused } = radioData;
    const [songName, saveSongName] = useState('');


    useNuiEvent<any>('radioData', (data) => {
        setRadioData(data);
    });

    const handlePlay = () => {

        fetchNui('radioNui', { action: 'play', link: songLink, volume, plate: radioData.id });
    };

    const handlePlayFromList = (link: string) => {
        setSongLink(link);
        fetchNui('radioNui', { action: 'play', link: link, volume, plate: radioData.id });
    };


    const handlePause = () => {
        fetchNui('radioNui', { action: 'pause', plate: radioData.id });
    };

    const handleResume = () => {
        fetchNui('radioNui', { action: 'resume', plate: radioData.id });
    };

    const handleLinkChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setSongLink(event.currentTarget.value);
    };

    const handleVolumeChange = (value: number) => {
        if (radioData.id) {
            setVolume(value);
            fetchNui('radioNui', { action: 'vol', volume: value, plate: radioData.id });
        }
    };

    const handleTimeStampChange = (value: number) => {
        setRadioData((prevData: any) => ({
            ...prevData,
            timeStamp: value,
        }));
        if (radioData.id) {
            fetchNui('radioNui', { action: 'time', timeStamp: value, plate: radioData.id });
        }
    };

    const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setSearchTerm(event.currentTarget.value);
    };


    const filterSongs = (songs: any, searchTerm: string) => {
        if (!searchTerm) return songs;
        return Object.keys(songs).filter((key) =>
            songs[key].name.toLowerCase().includes(searchTerm.toLowerCase())
        ).reduce((res: { [key: string]: any }, key) => {
            res[key] = songs[key];
            return res;
        }, {});
    };

    const filteredSongs = filterSongs(radioData.playlist, searchTerm);

    const formatTime = (seconds: number) => {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return `${minutes}:${remainingSeconds < 10 ? '0' : ''}${remainingSeconds}`;
    };


    const saveSong = async () => {
        const save = await fetchNui('radioNui', { action: 'saveSong', songName, songLink, ...radioData });
    };

    const handleSaveName = (event: React.ChangeEvent<HTMLInputElement>) => {
        saveSongName(event.currentTarget.value);
    };

    return (
        <Transition mounted={visible} transition="fade" duration={400} timingFunction="ease">
            {(styles) => (
                <div style={{ ...styles }} className='radio'>


                    <div className='player'>

                        <Card shadow="xs" padding="xs" withBorder>
                            <Stack spacing={30}>

                                <Group >
                                    <ActionIcon
                                        onClick={soundExists ? handleResume : handlePlay}
                                        variant="light"
                                        color={soundExists ? 'blue' : 'teal'}
                                    >
                                        <IconPlayerPlay size={20} />
                                    </ActionIcon>

                                    <ActionIcon
                                        onClick={handlePause}
                                        disabled={!soundExists}
                                        variant="light"
                                        color="pink"
                                    >
                                        <IconPlayerPause size={20} />
                                    </ActionIcon>
                                </Group>

                                <Slider
                                    min={0}
                                    max={radioData.maxDuration || 100}
                                    value={radioData.timeStamp || 0}
                                    onChange={handleTimeStampChange}
                                    step={1}
                                    label={formatTime}
                                    marks={[
                                        { value: 0, label: '0:00' },
                                        { value: radioData.maxDuration || 100, label: formatTime(radioData.maxDuration || 0) },
                                    ]}
                                />
                                <Slider
                                    min={0}

                                    max={100}
                                    value={volume}
                                    onChange={handleVolumeChange}
                                    step={1}
                                    label={(value) => `${value}%`}
                                    marks={[
                                        { value: 0, label: '0' },
                                        { value: 100, label: '100' },
                                    ]}
                                    sx={{ marginBottom: 15 }}
                                />

                            </Stack>
                        </Card>


                        <Card shadow="xs" padding="xs" withBorder>

                            <TextInput
                                value={songLink}
                                onChange={handleLinkChange}
                                placeholder="Enter song link"

                            />

                            <TextInput
                                onChange={handleSaveName}
                                label="Save song"
                                placeholder="Save as..."
                                rightSection={
                                    <ActionIcon
                                        onClick={() => saveSong()}
                                        variant="light"
                                        color='teal'
                                    >
                                        <IconDeviceFloppy />
                                    </ActionIcon>
                                }
                            />

                        </Card>
                    </div>


                    <Stack spacing={5}>

                        <Group spacing={5}>
                            <TextInput
                                value={searchTerm}
                                onChange={handleSearchChange}
                                placeholder="Search..."
                                icon={<IconSearch size={20} />}
                                w={279}
                            />
                            <ActionIcon
                                onClick={handlePause}
                                variant="light"
                                color="red"
                                size={36.5}
                            >
                                <IconX size={20} />
                            </ActionIcon>
                        </Group>

                        <ScrollArea h={354} w={320} scrollbarSize={0}>
                            <Stack spacing={5}>
                                {Object.keys(filteredSongs).map((key: string) => {
                                    const song = filteredSongs[key];
                                    return (
                                        <Card className='song' withBorder p={10} key={key}>
                                            <div className="song-name">{song.name}</div>
                                            <Group spacing={5}>
                                                <ActionIcon
                                                    onClick={() => handlePlayFromList(song.link)}
                                                    variant="light"
                                                    color={soundExists ? 'blue' : 'teal'}
                                                >
                                                    <IconPlayerPlay size={20} />
                                                </ActionIcon>
                                                <ActionIcon
                                                    onClick={handlePause}
                                                    variant="light"
                                                    color="red"
                                                >
                                                    <IconTrash size={20} />
                                                </ActionIcon>
                                            </Group>
                                        </Card>
                                    );
                                })}
                            </Stack>
                        </ScrollArea>
                    </Stack>

                </div>
            )}
        </Transition >
    );
};

export default RadioComponent;