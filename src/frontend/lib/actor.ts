import { idlFactory } from '$declarations';
import type { _SERVICE } from '$declarations/backend.did';

import {
	type Identity,
	type ActorSubclass,
	HttpAgent,
	Actor,
} from '@dfinity/agent';

export const getActor = async (identity: Identity): Promise<ActorSubclass<_SERVICE>> => {
	const canisterId = import.meta.env.VITE_BACKEND_CANISTER_ID as string;

	const agent = await getAgent(identity);

	return Actor.createActor(idlFactory, {
		agent,
		canisterId
	});
};

const getAgent = async (identity: Identity): Promise<HttpAgent> => {
	const host =
		import.meta.env.MODE === 'development' ? 'http://localhost:8080/' : 'https://icp0.io';

	const agent: HttpAgent = new HttpAgent({ identity, host });

	if (import.meta.env.MODE === 'development') {
		await agent.fetchRootKey();
	}

	return agent;
};
