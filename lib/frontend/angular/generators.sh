#!/bin/bash

# Gera componente Angular
generate_angular_component() {
    local name="$1"
    local dir="src/app/components/$name"
    
    mkdir -p "$dir"
    
    # Componente
    cat > "$dir/$name.component.ts" << EOF
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-$name',
  templateUrl: './$name.component.html',
  styleUrls: ['./$name.component.scss']
})
export class ${name}Component implements OnInit {
  constructor() { }

  ngOnInit(): void {
  }
}
EOF

    # Template
    cat > "$dir/$name.component.html" << EOF
<div class="${name}">
  <!-- Your template here -->
</div>
EOF

    # Estilos
    cat > "$dir/$name.component.scss" << EOF
.${name} {
  // Your styles here
}
EOF

    # Testes
    cat > "$dir/$name.component.spec.ts" << EOF
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ${name}Component } from './$name.component';

describe('${name}Component', () => {
  let component: ${name}Component;
  let fixture: ComponentFixture<${name}Component>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ${name}Component ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(${name}Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
EOF
}

# Gera serviço Angular
generate_angular_service() {
    local name="$1"
    local dir="src/app/services"
    
    mkdir -p "$dir"
    
    cat > "$dir/$name.service.ts" << EOF
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '@env/environment';

@Injectable({
  providedIn: 'root'
})
export class ${name}Service {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) { }

  getAll(): Observable<any[]> {
    return this.http.get<any[]>(\`\${this.apiUrl}/${name.toLowerCase()}\`);
  }

  getById(id: string): Observable<any> {
    return this.http.get<any>(\`\${this.apiUrl}/${name.toLowerCase()}/\${id}\`);
  }

  create(data: any): Observable<any> {
    return this.http.post<any>(\`\${this.apiUrl}/${name.toLowerCase()}\`, data);
  }

  update(id: string, data: any): Observable<any> {
    return this.http.put<any>(\`\${this.apiUrl}/${name.toLowerCase()}/\${id}\`, data);
  }

  delete(id: string): Observable<any> {
    return this.http.delete<any>(\`\${this.apiUrl}/${name.toLowerCase()}/\${id}\`);
  }
}
EOF
}

# Gera guard Angular
generate_angular_guard() {
    local name="$1"
    local dir="src/app/guards"
    
    mkdir -p "$dir"
    
    cat > "$dir/$name.guard.ts" << EOF
import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, UrlTree, Router } from '@angular/router';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ${name}Guard implements CanActivate {
  constructor(private router: Router) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {
    // Your guard logic here
    return true;
  }
}
EOF
}