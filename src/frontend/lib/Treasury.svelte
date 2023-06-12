<script lang="ts">
	import { treasuryStore } from '$lib/treasury.store';
	import { onMount } from 'svelte';

	let supply: bigint | null | undefined = null;

	onMount(async () => {
		supply = $treasuryStore;
	});

	$: supply = $treasuryStore;
</script>

<span class="text-tertiary-900">
	Treasury: <span class="font-medium text-xl">{supply}</span>
</span>
