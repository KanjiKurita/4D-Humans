FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# 必要なパッケージをインストールする
RUN apt-get update && \
    apt-get install -y wget bzip2 g++ libgl1-mesa-glx libegl1-mesa ninja-build git libglib2.0-0 libosmesa6-dev \
    libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 libgl1-mesa-dri mesa-utils && \
    rm -rf /var/lib/apt/lists/*

# 環境変数を設定
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV PYOPENGL_PLATFORM=osmesa

# Anacondaをダウンロードしてインストールする
RUN wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh && \
    sh Anaconda3-2023.09-0-Linux-x86_64.sh -b -p /opt/anaconda3 && \
    rm Anaconda3-2023.09-0-Linux-x86_64.sh

# Anacondaのパスを設定する
ENV PATH /opt/anaconda3/bin:$PATH

WORKDIR /4D-Humans
COPY . .

# Anacondaのデフォルトenvを4D-humansに変更
ARG env_name=4D-humans
RUN conda create -yn ${env_name} python=3.10
ENV CONDA_DEFAULT_ENV ${env_name}
RUN echo "conda activate ${env_name}" >> ~/.bashrc
ENV PATH /opt/conda/envs/${env_name}/bin:$PATH

# Pythonパッケージをインストール
RUN conda install pytorch torchvision torchaudio cudatoolkit=11.8 -c pytorch
RUN pip install pycocotools
RUN pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio==2.0.2 --index-url https://download.pytorch.org/whl/cu118
RUN pip install -v -e .[all]
RUN pip uninstall -y PyOpenGL PyOpenGL_accelerate
RUN pip install PyOpenGL PyOpenGL_accelerate

# pklの取得（ファイルが存在しない場合のみ取得）
RUN wget -nc https://github.com/classner/up/raw/master/models/3D/basicModel_neutral_lbs_10_207_0_v1.0.0.pkl && \
    mkdir -p data/ && \
    mv basicModel_neutral_lbs_10_207_0_v1.0.0.pkl data/

# コンテナ側のリッスンポート番号
EXPOSE 8888

# ENTRYPOINT命令はコンテナ起動時に実行するコマンドを指定
ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]

# CMD命令はコンテナ起動時に実行するコマンドを指定
CMD ["--notebook-dir=/4D-Humans"]