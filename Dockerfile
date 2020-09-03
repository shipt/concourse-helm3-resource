FROM alpine/helm:3.3.1

ARG KUBECTL_SOURCE=kubernetes-release/release
ENV KUBECTL_ARCH="linux/amd64"

RUN apk add --update --upgrade --no-cache ca-certificates jq bash curl git gettext libintl

ARG KUBECTL_TRACK=stable.txt

RUN KUBECTL_VERSION=$(curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_TRACK}") && \
  curl -SsL --retry 5 "https://storage.googleapis.com/${KUBECTL_SOURCE}/${KUBECTL_VERSION}/bin/${KUBECTL_ARCH}/kubectl" > /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

ADD assets /opt/resource
RUN chmod +x /opt/resource/*

ARG HELM_PLUGINS="https://github.com/helm/helm-2to3"
RUN for i in $(echo $HELM_PLUGINS | xargs -n1); do helm plugin install $i; done

RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
  install kustomize /usr/local/bin/kustomize

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
