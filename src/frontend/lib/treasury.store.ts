import { writable, type Readable } from 'svelte/store';
import { treasury } from './api';

export interface TreasuryStore extends Readable<bigint> {
	update: () => Promise<void>;
}

const init = async (): Promise<TreasuryStore> => {
	const supply = await treasury();

	const { subscribe, set } = writable<bigint>(supply);

	return {
		subscribe,

		update: async () => {
			set(await treasury());
		}
	};
};

export const treasuryStore: TreasuryStore = await init();
