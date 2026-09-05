"""MNE-Python Brainstorm somatosensory MEG demonstration."""

from pathlib import Path

import mne
import numpy as np
from mne.datasets.brainstorm import bst_raw


def run_pipeline():
    """Run the Brainstorm Median Nerve CTF analysis using updated MNE-Python standards."""
    print(__doc__)

    # 1. Download / locate the Brainstorm example dataset
    data_path = Path(bst_raw.data_path(verbose=False))
    raw_fname = (
        data_path
        / "MEG"
        / "bst_raw"
        / "subj001_somatosensory_20111109_01_AUX-f.ds"
    )

    # 2. Read CTF raw data
    raw = mne.io.read_raw_ctf(raw_fname, preload=True)

    # 3. Fix channel types & apply bandpass filter
    raw.set_channel_types({"EEG058": "eog"})
    
    # 4. Correct stimulus artifact on RAW data before epoching (Modern API)
    events = mne.find_events(raw, stim_channel="UPPT001")
    event_id = 2  # Right-hand somatosensory stimulation
    
    # Correct electrical artifact from stimulus (tmin=-0.002s to tmax=0.006s around event)
    mne.preprocessing.fix_stim_artifact(
        raw, events=events, event_id=event_id, tmin=-0.002, tmax=0.006
    )

    # 5. Compute and inspect Power Spectral Density (PSD)
    raw.compute_psd(fmax=100).plot()

    # 6. Select MEG + EOG channels excluding bad channels
    picks = mne.pick_types(
        raw.info,
        meg=True,
        eeg=False,
        stim=False,
        eog=True,
        exclude="bads",
    )

    # 7. Create Epochs (Preload=True is safer for modern operations)
    epochs = mne.Epochs(
        raw,
        events,
        event_id=event_id,
        tmin=-0.1,
        tmax=0.3,
        picks=picks,
        baseline=(None, 0),
        reject={
            "mag": 4e-12,
            "eog": 250e-6,
        },
        preload=True,
    )

    # 8. Average epochs into an evoked response
    evoked = epochs.average()

    # 9. Correct 4ms CTF hardware trigger latency delay
    evoked.shift_time(-0.004)

    # 10. Visualization
    evoked.plot(spatial_colors=True)
    evoked.plot_topomap(
        times=np.array([0.016, 0.030, 0.060, 0.070]),
        ch_type="mag",
    )

    return raw, events, epochs, evoked


if __name__ == "__main__":
    run_pipeline()
