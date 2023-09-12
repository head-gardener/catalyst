FROM ubuntu:latest

RUN yes | unminimize

RUN apt-get update && apt-get install -y \
  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ \
  pkg-config unzip git man-db \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --single-branch \
  https://github.com/neovim/neovim ~/neovim \
  && cd ~/neovim \
  && make CMAKE_BUILD_TYPE=Release \
  && make CMAKE_INSTALL_PREFIX=$HOME/local/nvim install

RUN git clone https://github.com/nvim-lua/plenary.nvim \
  ~/.local/share/nvim/site/pack/packer/start/plenary.nvim
RUN git clone https://github.com/MunifTanjim/nui.nvim \
  ~/.local/share/nvim/site/pack/packer/start/nui.nvim

WORKDIR /root

RUN mkdir -p .local/share/nvim/site/pack/packer/start/catalyst
COPY ./ .local/share/nvim/site/pack/packer/start/catalyst/

CMD /root/local/nvim/bin/nvim --headless -c ":PlenaryBustedDir ~/.local/share/nvim/site/pack/packer/start/catalyst/tests/catalyst/"
