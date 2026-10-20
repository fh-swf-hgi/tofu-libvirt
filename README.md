# OpenTofu Libvirt Demo

Dieses Repository enthält eine Beispielkonfiguration mit [OpenTofu](https://opentofu.org/) zur Bereitstellung von virtuellen Maschinen via Libvirt.

### 1. Repository klonen und initialisieren
Klonen Sie das Repository und initialisieren Sie OpenTofu:

```bash
git clone [https://github.com/fh-swf-hgi/tofu-libvirt](https://github.com/fh-swf-hgi/tofu-libvirt)
cd tofu-libvirt/
tofu init
```

### 2. SSH-Key generieren (Voraussetzung)

Damit sich die virtuellen Maschinen später korrekt konfigurieren und per SSH erreichen lassen, wird ein SSH-Schlüsselpaar benötigt. Falls noch keines existiert, erstellen Sie es mit:

```bash
ssh-keygen -t ed25519
```

*(Bestätigen Sie die Standardpfade mit Enter).*

### 3. OpenTofu Plan & Apply

Prüfen Sie die geplante Infrastruktur und wenden Sie die Konfiguration an:

```bash
tofu plan
tofu apply
```

Bestätigen Sie den Vorgang mit `yes`, wenn Sie dazu aufgefordert werden. OpenTofu erstellt nun die VMs im Hintergrund über Libvirt.

## Zugriff auf die VMs

Nachdem das Deployment erfolgreich durchgelaufen ist, können Sie die Dienste und VMs wie folgt testen:

### Web-Dienst aufrufen (per `curl`)

Überprüfen Sie den laufenden Web-Dienst auf der entsprechenden IP-Adresse:

```bash
curl [http://10.20.0.10:8080](http://10.20.0.10:8080)

```

### Per SSH in die VM verbinden

Loggen Sie sich in die erstellte virtuelle Maschine ein (Standardbenutzer `debian`):

```bash
ssh debian@10.20.0.20

```

Um sich auszuloggen, schließen Sie die Shell mit `exit`.

### Grafische Verwaltung mit `virt-manager`

Falls Sie eine lokale grafische Benutzeroberfläche (Desktop) auf dem Host nutzen, können Sie den Virtual Machine Manager starten, um die VMs visuell zu überwachen:

```bash
virt-manager

```

---

## Aufräumen

Wenn Sie die Demo beenden und alle Ressourcen (VMs, Netzwerke etc.) wieder löschen möchten, führen Sie folgenden Befehl aus:

```bash
tofu destroy

```

```
