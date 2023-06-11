<script lang="ts">
	import { onMount } from 'svelte';
	import { postComment } from './api';
	import Button from '$lib/Button.svelte';
	import { commentsStore } from './comments.store';
	import { createEventDispatcher } from 'svelte';

	const dispatch = createEventDispatcher();

	let comment: string;
	let input: HTMLInputElement;

	let text = 'Submit';

	onMount(async () => {
		input = document.getElementById('comment') as HTMLInputElement;
	});

	const post = async () => {
		input.disabled = true;
		text = 'Posting...';

		const result = await postComment(comment);

		if ('ok' in result) {
			comment = '';
			dispatch('updateUser');
			await commentsStore.update();
		} else if ('err' in result) {
			'AnonNotAllowed' in result.err ? (message = 'Anon not allowed!') : {};
			'InvalidComment' in result.err ? (message = 'Invalid comment!') : {};
			'TimeRemaining' in result.err
				? (message = 'Wait ' + Math.round(Number(result.err.TimeRemaining) / 10 ** 9) + ' seconds')
				: {};
			visible = true;
		}

		input.disabled = false;
		text = 'Submit';
	};

	let visible: boolean = false;
	let message: string = '';
</script>

<div class="flex justify-between mb-10">
	<label class="label flex-grow mr-4">
		<input bind:value={comment} id="comment" class="input" type="text" placeholder="Comment" />
	</label>
	<Button {text} on:click={post} />
</div>


{#if visible}
    <aside class="alert variant-ghost">
        <div><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
			<path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
		  </svg>
		</div>
        <div class="alert-message">
            <h3 class="h3">WARNING</h3>
            <p>{message}</p>
        </div>
        <div class="alert-actions">
			<Button text="Close" on:click={() => visible = false} />
		</div>
    </aside>
{/if}
            
