
{{- define "initmysql.tpl" -}}
        image: mysql:5.7
        command: ["bash", "-c", "/init.sh"]
        volumeMounts:
        - name: conf
          mountPath: /mnt/conf.d
        - name: mysql-config
          mountPath: /mnt/config-map
        - name: mysql-scripts
          mountPath: /init.sh
          subPath: init.sh
{{- end -}}

{{- define "clonemysql.tpl" -}}
        image: gcr.io/google-samples/xtrabackup:1.0
        command: ["bash", "-c", "/clone.sh"]
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        - name: mysql-scripts
          mountPath: /clone.sh
          subPath: clone.sh
{{- end -}}

{{- define "mysql.tpl" -}}
        image: mysql:5.7
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "1"
        ports:
        - name: mysql
          containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
{{- end -}}

{{- define "xtrabackup.tpl" -}}
        image: gcr.io/google-samples/xtrabackup:1.0
        ports:
        - name: xtrabackup
          containerPort: 3307
        command: ["bash", "-c", "/backup.sh"]
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        - name: mysql-scripts
          mountPath: /backup.sh
          subPath: backup.sh
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
{{- end -}}

{{- define "allvulumes.tpl" -}}
      volumes:
      - name: conf
        emptyDir: {}
      - name: mysql-config
        configMap:
          name: mysql-config
      - name: mysql-scripts
        configMap:
          name: mysql-scripts
          items:
            - key: init.sh
              path: init.sh
              mode: 0755
            - key: clone.sh
              path: clone.sh
              mode: 0755
            - key: backup.sh
              path: backup.sh
              mode: 0755
{{- end -}}

{{- define "pvc.tpl" -}}
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: {{.Values.global.storageSize}}
      storageClassName: {{.Values.global.storageClassName}}
{{- end -}}