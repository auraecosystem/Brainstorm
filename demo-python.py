"""MNE-Python Brainstorm somatosensory MEG demonstration."""

from pathlib import Path

import mne
import numpy as np
from mne.datasets.brainstorm import bst_raw


def test():
    """Run the Brainstorm Median Nerve CTF analysis using MNE-Python."""

    print(__doc__)

    # Download / locate the Brainstorm example dataset.
    data_path = Path(bst_raw.data_path())

    # Locate the CTF MEG recording.
    raw_fname = (
        data_path
        / "MEG"
        / "bst_raw"
        / "subj001_somatosensory_20111109_01_AUX-f.ds"
    )

    # Read the CTF dataset.
    raw = mne.io.read_raw_ctf(raw_fname, preload=True)

    # Inspect raw data.
    raw.plot()

    # Treat EEG058 as an EOG channel.
    raw.set_channel_types({"EEG058": "eog"})

    # Inspect power spectral density.
    raw.compute_psd().plot()

    # Optional 60-Hz line-noise suppression:
    # raw.notch_filter(np.arange(60, 181, 60))

    # Detect stimulus events.
    events = mne.find_events(
        raw,
        stim_channel="UPPT001",
    )

    # Event 2 = right-hand somatosensory stimulation.
    event_id = 2

    # Select MEG + EOG channels while excluding bad channels.
    picks = mne.pick_types(
        raw.info,
        meg=True,
        eeg=False,
        stim=False,
        eog=True,
        exclude="bads",
    )

    # Create epochs from -100 ms to +300 ms around each event.
    epochs = mne.Epochs(
        raw,
        events,
        event_id,
        tmin=-0.1,
        tmax=0.3,
        picks=picks,
        baseline=(None, 0),
        reject={
            "mag": 4e-12,
            "eog": 250e-6,
        },
        preload=False,
    )

    # Average epochs into an evoked response.
    evoked = epochs.average()

    # Correct the stimulus artifact.
    mne.preprocessing.fix_stim_artifact(evoked)

    # Correct the 4-ms hardware delay.
    evoked.shift_time(-0.004)

    # Plot the evoked response.
    evoked.plot()

    # Plot topographic maps at selected times.
    evoked.plot_topomap(
        times=np.array([
            0.016,
            0.030,
            0.060,
            0.070,
        ])
    )

    return raw, events, epochs, evoked


if __name__ == "__main__":
    test()
