### docker compose up前の準備
gpuを使用するのでホストマシン側でも色々入れる必要があります。
Windows11 + wsl + ubuntu + docker + docker compose 向けの導入手順です。

1. [cuda 11.8をダウンロードしてインストール](https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_522.06_windows.exe)
```
https://developer.nvidia.com/cuda-11-8-0-download-archive
```
2. wslに nvidia-container-toolkit を追加
```
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && \
    sudo apt-get update
```

```
sudo apt-get install -y nvidia-container-toolkit
```

### docker compose up
0. first time
```
docker compose up --build
```

### afte docker compose up
- How to run image demo
```
docker exec  -it type_your_container_name bash

wget https://github.com/classner/up/raw/master/models/3D/basicModel_neutral_lbs_10_207_0_v1.0.0.pkl
mkdir data/
mv basicModel_neutral_lbs_10_207_0_v1.0.0.pkl data/

python demo.py --img_folder example_data/images --out_folder demo_out --batch_size=48 --side_view --save_mesh --full_frame
```

