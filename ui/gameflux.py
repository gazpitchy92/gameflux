import tkinter as tk
from pathlib import Path

class MonitorApp:
    def __init__(self, root):
        root.title("Renice Gamemode Monitor")
        root.iconphoto(True, tk.PhotoImage(file="/etc/gameflux/ui/icon.png"))
        root.geometry("500x700")
        root.configure(bg="#1e1e1e")

        status_frame = tk.Frame(root, bg="#1e1e1e")
        status_frame.pack(side="top", fill="x", padx=10, pady=10)

        tk.Label(status_frame, text="Status:", font=("Arial", 12, "bold"), bg="#1e1e1e", fg="#ffffff").grid(row=0, column=0, sticky="w")

        self.status_label = tk.Label(status_frame, text="", font=("Arial", 12), bg="#1e1e1e", fg="#ffffff")
        self.status_label.grid(row=0, column=1, sticky="w", padx=5)

        self.status_indicator = tk.Canvas(status_frame, width=20, height=20, highlightthickness=0, bg="#1e1e1e")
        self.status_indicator.grid(row=0, column=2, padx=10)

        logs_frame = tk.Frame(root, bg="#1e1e1e")
        logs_frame.pack(side="bottom", fill="both", expand=True)

        self.logs = [
            ("  Renice Logs", "/etc/gameflux/logs/pid-log.txt"),
            ("  Downgraded Programs", "/etc/gameflux/flags/downgrade-pid.txt"),
            ("  Upgraded Game PID", "/etc/gameflux/flags/pid.txt"),
        ]

        self.log_widgets = {}

        for name, path in self.logs:
            section_frame = tk.Frame(logs_frame, bg="#1e1e1e")
            section_frame.pack(side="top", fill="both", expand=True, pady=5)

            tk.Label(section_frame, text=name, font=("Arial", 12, "bold"), bg="#1e1e1e", fg="#ffffff").pack(anchor="w")
            text_widget = tk.Text(section_frame, height=8, wrap="none", bg="#2e2e2e", fg="#ffffff", insertbackground="#ffffff", relief="flat")
            text_widget.pack(fill="both", expand=True, padx=10)
            text_widget.config(state="disabled")
            self.log_widgets[path] = text_widget

        self.update_ui()

    def read_file(self, path):
        p = Path(path)
        if p.exists():
            return p.read_text().strip().lower()
        return "false"

    def update_ui(self):
        status = self.read_file("/etc/gameflux/flags/status.txt")
        self.status_label.config(text=status)

        color = "#00ff00" if status == "true" else "#ff5555"
        self.status_indicator.delete("all")
        self.status_indicator.create_rectangle(0, 0, 20, 20, fill=color, outline=color)

        for path, widget in self.log_widgets.items():
            widget.config(state="normal")
            widget.delete("1.0", tk.END)
            p = Path(path)
            if p.exists():
                widget.insert(tk.END, p.read_text())
            widget.see(tk.END)
            widget.config(state="disabled")

        root.after(5000, self.update_ui)

if __name__ == "__main__":
    root = tk.Tk()
    app = MonitorApp(root)
    root.mainloop()
