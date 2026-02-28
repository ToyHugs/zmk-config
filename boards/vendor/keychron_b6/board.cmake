# Copyright (c) 2024 The ZMK Contributors
# SPDX-License-Identifier: MIT

board_runner_args(uf2 "--board-id=keychron_b6")
include(${ZEPHYR_BASE}/boards/common/uf2.board.cmake)
