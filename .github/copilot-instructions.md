# ZMK Config – Copilot Instructions

## Project Overview

This is a **ZMK firmware configuration repository** (based on [unified-zmk-config-template](https://github.com/zmkfirmware/unified-zmk-config-template)). It defines custom keyboard hardware (boards) and/or keymaps as a [ZMK module](https://zmk.dev/docs/features/modules). Firmware is **built entirely via GitHub Actions** — there is no local build step required for users.

## Repository Structure

```
build.yaml            # GHA build matrix: defines board/shield/snippet combos to compile
config/west.yml       # West manifest pinning ZMK version (currently v0.3)
zephyr/module.yml     # Declares this repo as a Zephyr module with board_root: .
boards/
  vendor/<id>/        # Full board definition (MCU-level, nRF52840 target)
  shields/            # Shield definitions (for pro-micro/interconnect-based splits)
old-config/           # Legacy Keychron B6 keymap (reference only, not built)
docs/                 # ZMK documentation snapshots (reference only)
.zmk/                 # Local west workspace for development (not committed source)
```

## Build System

- **CI**: Push to `main` triggers `.github/workflows/build.yml`, which calls `zmkfirmware/zmk/.github/workflows/build-user-config.yml@v0.3`.
- **`build.yaml`** controls what gets compiled. Add entries here to build new targets:
  ```yaml
  include:
    - board: example_id
    - board: nice_nano_v2
      shield: corne_left
  ```
- **Output**: `.uf2` files (configured via `CONFIG_BUILD_OUTPUT_UF2=y` in `_defconfig`).
- **ZMK version**: Pinned to `v0.3` in both `config/west.yml` and `.github/workflows/build.yml` — update both together.

## Board Definition Pattern (`boards/vendor/<id>/`)

Each board requires this file set (all generated from template, then edited):

| File                      | Purpose                                                      |
| ------------------------- | ------------------------------------------------------------ |
| `board.yml`               | Declares board name, vendor, SoC (`nrf52840`)                |
| `Kconfig.example_id`      | Selects SoC variant (`SOC_NRF52840_QIAA`), enables retention |
| `Kconfig.defconfig`       | Sets `ZMK_KEYBOARD_NAME`, enables USB/BLE Kconfig defaults   |
| `Kconfig`                 | Board-specific Kconfig options (usually empty)               |
| `example_id_defconfig`    | Mandatory Kconfig symbols (GPIO, PINCTRL, NVS, BLE, USB)     |
| `example_id.dts`          | Main devicetree: kscan matrix, LEDs, chosen nodes            |
| `example_id-pinctrl.dtsi` | UART/SPI pin assignments via `NRF_PSEL()`                    |
| `example_id-layouts.dtsi` | Physical layout for ZMK Studio (`zmk,physical-layout`)       |
| `example_id.keymap`       | Default keymap shipped with the board                        |
| `example_id.conf`         | User-facing Kconfig stubs (commented-out feature toggles)    |
| `example_id.yaml`         | Twister board metadata (arch, toolchain, features)           |
| `example_id.zmk.yml`      | ZMK hardware metadata (features, outputs, url)               |
| `board.cmake`             | Flashing runner config                                       |

## Key Conventions

- **Diode direction**: `col2row` is the default in templates; `row2col` requires swapping GPIO flags to `GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN` on cols and `GPIO_ACTIVE_HIGH` on rows.
- **Physical layout keys property**: Units are in centidecimal (1/100 U). 100 = 1U key width/height.
- **ZMK Studio support**: Add `features: [studio]` to `.zmk.yml` and keep `zmk,physical-layout` with a `keys` property. Remove `studio` feature if not needed.
- **Keymap includes**: Always include `<behaviors.dtsi>` and `<dt-bindings/zmk/keys.h>`; add `rgb.h`, `bt.h`, `outputs.h` only as needed.
- **Module naming**: Follow `zmk-<type>-<description>` (e.g. `zmk-keyboard-example`); set in `zephyr/module.yml`.

## Adding a New Keyboard

1. Run `zmk keyboard new` (ZMK CLI) to scaffold files in `boards/vendor/<id>/` or `boards/shields/<id>/`.
2. Edit the generated files to match real hardware (GPIO pins, matrix dimensions, SoC variant).
3. Add the board to `build.yaml` under `include`.
4. Push — GHA will build and produce a `.uf2` artifact.

## Reference: `old-config/b6/us/`

Legacy Keychron B6 config (shield-style, 8×18 matrix, custom `OUT_RECOVER`/`OUT_FN` macros, combo-based layer switching). Useful as a real-world example of complex keymaps with `hold-tap`, `combos`, and custom macros. **Not wired into `build.yaml`.**
