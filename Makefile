build:
	wasm-pack build
	cd www && pnpm i && pnpm build

start: build
	cd www && pnpm preview

dev: build
	cd www && pnpm start

clean:
	cargo clean
	rm -rf ./pkg ./www/dist ./www/node_modules