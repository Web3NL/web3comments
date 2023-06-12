<script lang="ts">
	// Preserve the order of these imports
	import '@skeletonlabs/skeleton/themes/theme-crimson.css';
	import '@skeletonlabs/skeleton/styles/skeleton.css';
	import { computePosition, autoUpdate, offset, shift, flip, arrow } from '@floating-ui/dom';
	import { storePopup } from '@skeletonlabs/skeleton';
	storePopup.set({ computePosition, autoUpdate, offset, shift, flip, arrow });

	import { browser } from '$app/environment';
	import { authStore } from '$lib/auth.store';

	const init = async () => Promise.resolve(syncAuthStore());

	const syncAuthStore = async () => {
		if (!browser) {
			return;
		}

		try {
			await authStore.sync();
		} catch (err: unknown) {
			console.error(err);
		}
	};
</script>

{#await init()}
	Loading...
{:then _}
	<slot />
{/await}
