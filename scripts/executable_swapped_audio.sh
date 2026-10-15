#!/usr/bin/env bash

pw-loopback -m '[[FL FR] [FR FL]]' \
        --capture-props='media.class=Audio/Sink node.name=swapped_audio node.description="Swapped Audio" audio.position=[FL,FR] node.passive=true' \
        --playback-props='audio.position=[FR,FL] stream.dont-remix=true'
