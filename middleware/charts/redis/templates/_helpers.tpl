
{{- define "redis.tpl" -}}
        image: {{.Values.image}}
        command: ["bash", "-c", "/init.sh"]
        ports:
        - name: redis
          containerPort: 6379
        volumeMounts:
        - name: redis-scripts
          mountPath: /init.sh
          subPath: init.sh
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
{{- end -}}

{{- define "allvulumes.tpl" -}}
      - name: redis-scripts
        configMap:
          name: redis-scripts
          items:
            - key: init.sh
              path: init.sh
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
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - redis
          topologyKey: "kubernetes.io/hostname"
   {{- end }}
{{- end }}