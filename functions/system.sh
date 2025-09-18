#!/bin/bash

clear_ram_buffer() {
    echo 3 | sudo tee /proc/sys/vm/drop_caches
}