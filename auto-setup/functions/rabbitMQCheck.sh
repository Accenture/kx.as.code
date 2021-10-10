checkRabbitMq() {
  if [ ! -f /usr/local/bin/rabbitmqadmin ]; then
      wget http://127.0.0.1:15672/cli/rabbitmqadmin
      chmod +x rabbitmqadmin
      mv rabbitmqadmin /usr/local/bin/rabbitmqadmin
      # Add bash auto-completion
      rabbitmqadmin --bash-completion | sudo tee /etc/bash_completion.d/rabbitmqadmin
      echo "source /etc/bash_completion.d/rabbitmqadmin" | sudo tee -a /home/${VM_USER}/.bashrc /home/${VM_USER}/.zshrc /root/.bashrc /root/.zshrc
  fi
}