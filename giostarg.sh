#!/bin/bash

# Función para verificar la clave de autorización
verificar_clave() {
    EXPIRATION_TIME=14400
    read -p "Por favor, ingresa la clave de autorización: " INPUT_KEY
    
    if [[ -f /etc/giostarg/key.txt ]]; then
        STORED_KEY=$(cut -d':' -f1 /etc/giostarg/key.txt)
        STORED_TIMESTAMP=$(cut -d':' -f2 /etc/giostarg/key.txt)
    else
        echo "Error: no se encontró ninguna clave almacenada."
        exit 1
    fi

    CURRENT_TIMESTAMP=$(date +%s)
    TIME_DIFF=$((CURRENT_TIMESTAMP - STORED_TIMESTAMP))

    if [[ "$INPUT_KEY" == "$STORED_KEY" && "$TIME_DIFF" -le "$EXPIRATION_TIME" ]]; then
        echo "Clave válida. Continuando con la instalación..."
    else
        echo "Clave inválida o expirada."
        exit 1
    fi
}

# Función para instalar dependencias necesarias
instalar_dependencias() {
    sudo apt-get update
    sudo apt-get install -y curl uuid-runtime lsb-release
    mkdir -p /etc/giostarg
}

# Función para mostrar la cabecera
mostrar_cabecera() {
    clear
    echo "≪━━─━━─━─━─━─━─━━─━━─━─━─◈─━━─━─━─━─━━─━─━━─━─━━─━≫"
    echo "  ❯❯❯❯❯❯ ꜱᴄʀɪᴩᴛ ᴍᴏᴅ GioStarg ❮❮❮❮❮❮ [Version 1]"
    echo "≪━━─━─━━━─━─━─━─━─━━─━─━─◈─━─━─━─━─━━━─━─━─━━━─━─━≫"
    
    OS=$(lsb_release -d | awk -F"\t" '{print $2}')
    HORA=$(TZ="America/Argentina/Buenos_Aires" date "+%H:%M:%S")
    IP=$(curl -s ifconfig.me)
    RAM_TOTAL=$(free -m | awk '/^Mem:/{print $2"MB"}')
    RAM_USADA=$(free -m | awk '/^Mem:/{print $3"MB"}')
    RAM_LIBRE=$(free -m | awk '/^Mem:/{print $4"MB"}')
    
    echo " OS : $OS       HORA: $HORA        IP: $IP"
    echo " RAM: $RAM_TOTAL    USADO: $RAM_USADA    LIBRE: $RAM_LIBRE"
    echo "————————————————————————————————————————————————————"
    echo "                    @giostarg"
    echo "————————————————————————————————————————————————————"
    
    echo " Usuarios: $(cat /etc/giostarg/usuarios.txt | wc -l)"
    echo " ONLINE: $(who | wc -l)       EXPIRADOS: (por implementar)      BLOQUEADO: (por implementar)"
    echo "————————————————————————————————————————————————————"
    echo " [1] ➛  ADMINISTRAR CUENTAS"
    echo " [2] ➛  PROTOCOLOS  HERRAMIENTAS"
    echo " [0] ➛  SALIR"
    echo "————————————————————————————————————————————————————"
    echo -n "► Selecione una Opcion: "
}

# Función para administrar cuentas de usuario
administrar_cuentas() {
    while true; do
        clear
        echo "≪━━─━━─━─━─━─━─━━─━━─━─━─◈─━━─━─━─━─━━─━─━━─━─━━─━≫"
        echo "❯❯❯❯❯❯ @giostarg ❮❮❮❮❮❮ [Version 1]"
        echo "≪━━─━─━━━─━─━─━─━─━━─━─━─◈─━─━─━─━─━━━─━─━─━━━─━─━≫"
        echo "————————————————————————————————————————————————————"
        echo "               ADMINISTRADOR DE USUARIOS"
        echo "————————————————————————————————————————————————————"
        echo " [1] ➛  CREAR NUEVO USUARIO"
        echo " [2] ➛  ELIMINAR USUARIOS"
        echo " [3] ➛  USUARIOS CONECTADOS"
        echo " [0] ➛  VOLVER"
        echo "————————————————————————————————————————————————————"
        echo -n "► Selecione una Opcion: "
        read opcion
        case $opcion in
            1) crear_usuario ;;
            2) eliminar_usuario ;;
            3) usuarios_conectados ;;
            0) break ;;
            *) echo "Opción inválida. Inténtelo de nuevo." ;;
        esac
    done
}

# Función para crear un nuevo usuario
crear_usuario() {
    echo "Ingrese el nombre de usuario (solo letras, mínimo 4 caracteres):"
    read nombre
    if [[ ! "$nombre" =~ ^[a-zA-Z]{4,}$ ]]; then
        echo "Nombre de usuario no válido."
        return
    fi
    
    echo "Ingrese la contraseña (solo letras, mínimo 4 caracteres):"
    read -s password
    if [[ ! "$password" =~ ^[a-zA-Z]{4,}$ ]]; then
        echo "Contraseña no válida."
        return
    fi
    
    echo "Ingrese los días de expiración:"
    read dias_expiracion
    
    echo "Ingrese el número máximo de conexiones:"
    read conexiones_max
    
    useradd -m -e $(date -d "$dias_expiracion days" +%Y-%m-%d) -s /bin/bash "$nombre"
    echo "$nombre:$password" | chpasswd
    echo "$nombre $conexiones_max" >> /etc/giostarg/usuarios.txt
    echo "Usuario creado exitosamente."
}

# Función para eliminar un usuario
eliminar_usuario() {
    echo "Usuarios disponibles:"
    cat /etc/giostarg/usuarios.txt | nl
    echo "Seleccione el número del usuario que desea eliminar:"
    read numero
    usuario=$(sed "${numero}q;d" /etc/giostarg/usuarios.txt | awk '{print $1}')
    userdel -r "$usuario"
    sed -i "${numero}d" /etc/giostarg/usuarios.txt
    echo "Usuario $usuario eliminado."
}

# Función para ver usuarios conectados
usuarios_conectados() {
    echo "Usuarios conectados actualmente:"
    who
    echo "--------------------------------"
    echo "Presione cualquier tecla para continuar..."
    read -n 1
}

# Función para el menú de protocolos y herramientas
menu_protocolos_herramientas() {
    while true; do
        clear
        echo "≪━━─━━─━─━─━─━─━━─━━─━─━─◈─━━─━─━─━─━━─━─━━─━─━━─━≫"
        echo "❯❯❯❯❯❯ @giostarg ❮❮❮❮❮❮ [Version 1]"
        echo "≪━━─━─━━━─━─━─━─━─━━─━─━─◈─━─━─━─━─━━━─━─━─━━━─━─━≫"
        echo "————————————————————————————————————————————————————"
        echo " [1] ➛ Instalar Ws 80"
        echo " [2] ➛ Desinstalar Ws"
        echo " [3] ➛ AUTO INICIAR SCRIPT ----------> [off]"
        echo " [4] ➛ TCP SPEED BBR        ---------> [Off]"
        echo " [5] ➛ ACTUALIZAR"
        echo " [6] ➛ DESINSTALAR"
        echo " [0] ➛ VOLVER"
        echo "————————————————————————————————————————————————————"
        echo -n "► Selecione una Opcion: "
        read opcion
        case $opcion in
            1) instalar_ws ;;
            2) desinstalar_ws ;;
            3) auto_iniciar_script ;;
            4) gestionar_tcp_bbr ;;
            5) actualizar_script ;;
            6) desinstalar_script ;;
            0) break ;;
            *) echo "Opción inválida. Inténtelo de nuevo." ;;
        esac
    done
}

# Función para instalar WebSocket en el puerto 80
# Función para instalar WebSocket en el puerto 80
instalar_ws() {
    sudo apt-get install -y python3-pip
    pip3 install flask flask-socketio
    cat <<EOF > /etc/giostarg/websocket.py
from flask import Flask, render_template
from flask_socketio import SocketIO

app = Flask(__name__)
socketio = SocketIO(app)

@app.route('/')
def index():
    return "WebSocket Server is running on port 80."

if __name__ == '__main__':
    socketio.run(app, port=80)
EOF
    sudo nohup python3 /etc/giostarg/websocket.py > /dev/null 2>&1 &
    echo "WebSocket instalado y ejecutándose en el puerto 80."
}

# Función para desinstalar WebSocket
desinstalar_ws() {
    sudo pkill -f websocket.py
    sudo apt-get remove --purge -y python3-pip
    echo "WebSocket desinstalado."
}

# Función para configurar el auto-inicio del script
auto_iniciar_script() {
    if grep -q "giostarg.sh" /etc/rc.local; then
        sudo sed -i '/giostarg.sh/d' /etc/rc.local
        echo "Auto-inicio desactivado."
    else
        echo "sudo /bin/bash /etc/giostarg/giostarg.sh &" | sudo tee -a /etc/rc.local > /dev/null
        echo "Auto-inicio activado."
    fi
}

# Función para gestionar TCP BBR
gestionar_tcp_bbr() {
    if lsmod | grep -q 'tcp_bbr'; then
        sudo modprobe -r tcp_bbr
        echo "TCP BBR desinstalado."
    else
        echo "net.core.default_qdisc = fq" | sudo tee -a /etc/sysctl.conf > /dev/null
        echo "net.ipv4.tcp_congestion_control = bbr" | sudo tee -a /etc/sysctl.conf > /dev/null
        sudo sysctl -p
        echo "TCP BBR instalado y activado."
    fi
}

# Función para actualizar el script
actualizar_script() {
    sudo wget -O /etc/giostarg/giostarg.sh https://github.com/tuusuario/tu-repo/raw/main/giostarg.sh
    sudo chmod +x /etc/giostarg/giostarg.sh
    echo "Script actualizado."
}

# Función para desinstalar el script
desinstalar_script() {
    sudo rm -f /etc/giostarg/giostarg.sh
    sudo rm -f /etc/giostarg/key.txt
    sudo rm -f /etc/giostarg/usuarios.txt
    sudo rm -f /etc/giostarg/websocket.py
    sudo pkill -f websocket.py
    echo "Script desinstalado."
}

# Función principal para manejar la selección del menú principal
menu_principal() {
    while true; do
        mostrar_cabecera
        read opcion
        case $opcion in
            1) administrar_cuentas ;;
            2) menu_protocolos_herramientas ;;
            0) exit 0 ;;
            *) echo "Opción inválida. Inténtelo de nuevo." ;;
        esac
    done
}

# Instalación inicial y verificación de clave
instalar_dependencias
verificar_clave

# Llamar a la función principal para iniciar el script
menu_principal
