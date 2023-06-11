import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { NodeModulesPolyfillPlugin } from '@esbuild-plugins/node-modules-polyfill';
import { readFileSync } from 'fs';
import { join, resolve } from 'path';

const network = process.env.DFX_NETWORK ?? 'local';

const readCanisterIds = ({ prefix }: { prefix?: string }): Record<string, string> => {
	const canisterIdsJsonFile =
		network === 'ic'
			? join(process.cwd(), 'canister_ids.json')
			: join(process.cwd(), '.dfx', 'local', 'canister_ids.json');

	try {
		type Details = {
			ic?: string;
			local?: string;
		};

		const config: Record<string, Details> = JSON.parse(readFileSync(canisterIdsJsonFile, 'utf-8'));

		return Object.entries(config).reduce((acc, current: [string, Details]) => {
			const [canisterName, canisterDetails] = current;

			return {
				...acc,
				[`${prefix ?? ''}${canisterName.toUpperCase()}_CANISTER_ID`]:
					canisterDetails[network as keyof Details]
			};
		}, {});
	} catch (e) {
		throw Error(`Could not get canister ID from ${canisterIdsJsonFile}: ${e}`);
	}
};

export default defineConfig({
	plugins: [sveltekit()],
	build: { 
		target: 'esnext',
	},
	resolve: {
		alias: {
			$declarations: resolve('./src/declarations')
		}
	},
	server: {
		proxy: {
			'/api': 'http://localhost:8080'
		}
	},

	optimizeDeps: {
		esbuildOptions: {
			// Node.js global to browser globalThis
			define: {
				global: 'globalThis'
			},
			// Enable esbuild polyfill plugins
			plugins: [
				// @ts-ignore
				NodeModulesPolyfillPlugin(),
				{
					name: 'fix-node-globals-polyfill',
					setup(build) {
						build.onResolve({ filter: /_virtual-process-polyfill_\.js/ }, ({ path }) => ({ path }));
					}
				}
			]
		}
	},

	define: {
		'process.env': {
			...readCanisterIds({}),
			DFX_NETWORK: network
		}
	}
});
