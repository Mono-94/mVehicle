import React, { useEffect, useState } from 'react';
import { fetchNui } from '../utils/fetchNui';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { isEnvBrowser } from '../utils/misc';
import Menu from './carkeys/MenuCarKeys';
import './index.scss';
import { Button, Card, Group, Stack } from '@mantine/core';
import KeyManager from './carkeys/ModalPlayerList';
import RadioComponent from './radio/radio';

const App: React.FC = () => {
  const [menuVisible, setMenuVisible] = useState(false);

  const [modalVisible, setModalVisible] = useState(false);

  const [radioVisible, setRadioVisible] = useState(false);

  useNuiEvent<boolean>('setVisibleMenu', setMenuVisible);

  useNuiEvent<boolean>('setVisibleModal', setModalVisible);

  useNuiEvent<boolean>('radio', setRadioVisible);

  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (e.code === 'Escape') {
        if (menuVisible) {
          if (!isEnvBrowser()) {
            fetchNui('ui:Close', { name: 'setVisibleMenu' });
          } else {
            setMenuVisible(false);
          }
        }
        if (radioVisible) {
          if (!isEnvBrowser()) {
            fetchNui('radioNui', { action: 'close' });
          } else {
            setRadioVisible(false);
          }
        }
        if (modalVisible) {
          if (!isEnvBrowser()) {
            fetchNui('ui:Close', { name: 'setVisibleModal' });
          } else {
            setModalVisible(false);
          }
        }
      }
    };

    window.addEventListener('keydown', keyHandler);

    return () => {
      window.removeEventListener('keydown', keyHandler);
    };
  }, [menuVisible, radioVisible, modalVisible]);

  return (
    <>
      {isEnvBrowser() &&
        <Card w={200} m={10} radius={2} p={6} style={{backgroundColor:'gray'}}>
          <Stack spacing={6}>
            <Button size="xs" color="dark" compact  onClick={() => { setMenuVisible(!menuVisible) }}>Personal Menu</Button>
            <Button size="xs" color="dark" compact  onClick={() => { setRadioVisible(!radioVisible) }}>Radio</Button>
            <Button size="xs" color="dark" compact  onClick={() => { setModalVisible(!modalVisible) }}>Key Modal</Button>
          </Stack>
        </Card>
      }


      <Menu visible={menuVisible} />
      <KeyManager visible={modalVisible} />
      <RadioComponent visible={radioVisible} />
    </>
  );
};

export default App;

