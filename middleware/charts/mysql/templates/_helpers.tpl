
{{- define "initmysql.tpl" -}}
        image: {{.Values.image}}
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
        image: {{.Values.xtrabackupImage}}
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
        image: {{.Values.image}}
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: {{ .Values.rootPassword }}
        - name: MYSQL_USER
          value: {{ .Values.username }}
        - name: MYSQL_PASSWORD
          value: {{ .Values.password }}
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
        image: {{.Values.xtrabackupImage}}
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
      {{- with .Values.global.storageClassName }}
      storageClassName: {{.}}
      {{- end }}
{{- end -}}

{{- define "nodeSelector.tpl"  }}
    {{- with .Values.global.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
    {{- end  }}
{{- end }}

{{- define "podAntiAffinity.tpl"  }}
   {{- if eq .Values.global.antiAffinity true }}
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - mysql
            topologyKey: "kubernetes.io/hostname"
   {{- end }}
{{- end }}