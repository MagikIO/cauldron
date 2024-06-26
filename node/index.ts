import consola from 'consola'
import Cauldron from './Cauldron';

const DEBUG = true;

(async () => {
  try {
    consola.wrapAll();

    const cauldron = await Cauldron.init(DEBUG);
    if (!cauldron) throw new Error('Cauldron not initialized');
    consola.success('Cauldron created');


    cauldron.info();


  } catch (error) { console.error(error); }
})().catch(console.error)
