  class Xprinter < Formula
    desc "Driver of xprinter"
    homepage "https://galaxycal.github.io/homebrew-xprinter/"
    url "https://github.com/GalaxyCal/homebrew-xprinter/releases/download/v1.0.0/xprinter-1.0.0.tar.xz"
    sha256 "2bacdf67ca39448f2cf78a79f9a58c3ba0c070dd111fb90c4496c28d8572ff95"
    version "1.0.0"
  
    def install
      bin.install "xprinter"
      bin.install "xprinter-server"
    end
  
    def post_install
      plist_xprinter_file = "/Library/LaunchAgents/com.max.startxprinter.plist"
      plist_server_file = "/Library/LaunchAgents/com.max.xprinterserver.plist"
  
      # 创建 Launchd 配置文件
      ohai "Creating Launchd plist file at #{plist_xprinter_file}"
      (plist_xprinter_file).write <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.max.startxprinter</string>
            <key>ProgramArguments</key>
            <array>
                <string>/usr/local/bin/xprinter</string>
                <string>server</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
        </dict>
        </plist>
      EOS
  
      ohai "Creating Launchd plist file at #{plist_server_file}"
      (plist_server_file).write <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.max.xprinterserver</string>
            <key>ProgramArguments</key>
            <array>
                <string>/usr/local/bin/xprinter-server</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
        </dict>
        </plist>
      EOS
  
      # 设置 plist 文件权限
      system "chmod", "755", plist_xprinter_file
      system "chmod", "755", plist_server_file
  
      # 重新加载 Launchd 配置文件
      ohai "Reloading Launchd plist file"
      system "sudo", "launchctl", "load", plist_xprinter_file
      system "sudo", "launchctl", "load", plist_server_file
  
      # 在后台运行 xprinter server 命令
      system "nohup", "/usr/local/bin/xprinter", "server", "> /dev/null 2>&1 &"
      # system "nohup", "/usr/local/bin/xprinter-server", "> /dev/null 2>&1 &"
  
      ohai "Post-install setup completed."
    end
  
    # test do
    #   system "#{bin}/xprinter", "--version"
    # end
  end
  